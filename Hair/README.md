目前头发的实时渲染主要基于两种方法：面片和导线

面片头发主要就是靠插片的方法通过Alpha Clip或者Alpha Blend的方法去做，这两种做法半透明排序都是一个很麻烦的问题，当想做多层头发时这种问题会更加明显，因为引擎对于半透明物体的片元的深度记录的是物体中心点的深度，当两层头发模型靠得太近时就会出现fighting，某些特定视角会出现一层突然出现在另外一层上面，并且使用Alpha Blend去实现时，需要使用两层材质，一层不透明渲染，一层透明渲染，然后使用TAA解决不透明部分Alpha clip带来的锯齿问题

后续自己制作导线的头发，然后实现一下MarschnerShadingmodel（但说实话kajiya已经能出很真实的效果了）
