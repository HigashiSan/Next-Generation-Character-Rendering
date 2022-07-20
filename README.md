# Next-Generation-Character-Rendering
My implementation for character rendering in unity URP, including eyes、face and hair.I will not upload any texture or obj resources, only describe the algrithm I used.

For face I will try to render with 4s and Pre-integration algrithmn.However, for pore-level details of the skin, this surface scattering is not the decisive factor, the key is diffuse illumination model.


![whole3](https://user-images.githubusercontent.com/56297955/179361834-bb214a9a-5adf-4dc7-9cbc-025b0a5aa565.png)


![whole6](https://user-images.githubusercontent.com/56297955/179361889-f8b11741-10da-4384-828d-242993711bf3.png)


For eyes, I will take a multi-layer eye structures method to render for a more realistic representation.Since I can't share the model and texture resources, I will only share the algorithm and shader code.

![image](https://user-images.githubusercontent.com/56297955/178153442-a370562f-6767-4f0a-83a5-53deed8fc9a6.png)


![Eye7](https://user-images.githubusercontent.com/56297955/178422245-31f2994c-9ce9-4656-8cbd-191631334310.png)


![泪腺](https://user-images.githubusercontent.com/56297955/180047962-629c084a-0d99-44a3-831c-b8c29c560a82.png)


And for hair, it is actually the most difficult one, I think Kajia's anisotropic algorithm has been enough to achieve a good results.But if you want more details, the hair model have to be more complicated, then the alpha blend will cause a serious problem: transparency sorting.So far, OIT has been a good solution.

Due to the hair rendered as transparent object, you can see the head through the hair, and that's strange.So I make another base hair material as the second material, which is rendered as opaque object. 

![image](https://user-images.githubusercontent.com/56297955/178423265-e8b344fc-e046-4045-9570-95dc93af9c11.png)


![Hair3TAA](https://user-images.githubusercontent.com/56297955/178422338-150899c6-b4f0-453e-a478-779dc65b61ad.png)


![Hair1TAA](https://user-images.githubusercontent.com/56297955/178422375-a429da55-ef3d-45b7-9149-51770bc127ec.png)
