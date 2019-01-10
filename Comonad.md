我来举个简单的haskell例子说明一下其他答主已经讲的Comonad的解构, 还有Comonad的对计算的结合和暴露context等功能.

因为duality principle，在Category Theory里面category oxxx是category xxx的dual就是把category xxx里面的箭头都调转的category。所以Comonad喵对应的自然是monad喵。

Haskell里面，Monad是用Type class 来编码的, `class Comonad`大该就是把`class Monad`里的那些function的type signature全部调转来的那种Type class.



我们把[地表最强男人](http://hackage.haskell.org/package/comonad-5.0.4/docs/Control-Comonad.html)EK[实现的Comonad](http://hackage.haskell.org/package/comonad-5.0.4/docs/Control-Comonad.html)盗出来, 看到它的function在type signature上和`class Monad`对称的关系.

```haskell
class Functor w => Comonad w where
  extract :: w a -> a
  duplicate :: w a -> w (w a)
  duplicate = extend id
  extend :: (w a -> b) -> w a -> w b
  extend f = fmap f . duplicate
  (=>>) :: w a -> (w a -> b) -> w b
  (=>>) = flip extend
```

据上定义, 实现一个简单的`Comonad stream`(参照[这里的stream notation](http://hackage.haskell.org/package/comonad-transformers-1.3.0/docs/Control-Comonad-Trans-Stream.html))

```haskell
data Stream a = a :< Stream a deriving Show
instance Functor Stream where
  fmap f (x :< xs) = f x :< fmap f xs
instance Comonad Stream where
  extract (x :< _) = x
  duplicate s@(_:<xs) = s :< duplicate xs

generate :: (a -> a) -> a -> Stream a
generate f x = x :< generate f x =>> (f . extract)

nats :: Stream Integer
nats = generate (+1) 0
```

* Comonad的解构功能, 主要看`duplicate :: w a -> w (w a)`这个套层的实现, 为了有意义的套层, 在套层的同时把原来w a的结构解开. 具体`Comonad Stream`里的实现中,不断把原来的Stream头尾分离,然后组成一个步进的2d stream.  
* Comonad的结合和暴露context的功能, 就要利用`(=>>) :: wa -> (wa->b) -> wb` (对应Monad结合功能的`(>>=)`的Comonad的dual), 可以拿到整个的新的stream然后暴露到后续的计算中去. 例如这个把`getWindowSum` (宽度为n窗口的元素和为新的元素) 和 (每一个元素加11) 两种计算结合在一起的例子:

```haskell
getWindowSum :: Integer -> Stream Integer -> Integer
getWindowSum n (x :< xs) 
  | n == 1 = x
  | n > 1 = x + getWindowSum (n-1) xs
  | otherwise = undefined

tensWindows = nats =>> getWindowSum 10 =>> ((+11) . extract)
```
(开脑洞Haskell可以弄一个codo notation对着do notation来干)



而解构功能的背后的原因主要要追溯到comonad 又是comonoid on the the category of endofunctors(有毒的dual梗).

- monoid主要带来`join : (w w) -> w`,  所以monad可以用来把积木叠成一个.
- comonoid带来的是`split : w -> (w w)`,  我们要实现有用的split,而不是简单copy多一个出来, 我们需要w是本身能够split开来的结构.

其实我们大多时候都在叠积木, 而不是在拆积木, 结果comond和monad本是同根生, monad大行其道, comonad墙角哭泣.



最后升华一下, 有伟大的Lens来为comonad的实际用途正名, Lenses are the coalgebras for the costate comonad(哭倒在厕所dulity).