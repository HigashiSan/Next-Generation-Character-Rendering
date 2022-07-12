In order to render realistic eyes, we need to use the actual human eye structure.

But I rarely see other articles that explain in detail how to do these layers of rendering. For example, without Eye Occlusion, the transition between the eyeball and the upper eyelid will be stiff, and there will be no dark shadow around the eye, so it won't look nice and realistic.

![image](https://user-images.githubusercontent.com/56297955/178516787-36260b19-50db-444f-b54a-d84ea258c7ac.png)

I use Maya to make the eye occlusion and eye water model, it is relatively easy.

First is to render the eye ball.I want eye iris and pupil both can be scaled easily, and can control cloudy color of the iris.


https://user-images.githubusercontent.com/56297955/178552361-02c1bf9e-fd2a-4515-943b-edfcece23ea8.mp4


I also used real physics formulas to simulate eye refraction.And can adjust the distance between the pupil and cornea.

Here you can see the effect with or without the refraction

https://user-images.githubusercontent.com/56297955/178555296-bc5212fc-5bf2-4286-8d98-e7285758cf79.mp4

https://user-images.githubusercontent.com/56297955/178555332-1f96b1b1-bee6-456a-9bd3-7156971f79f1.mp4

For the light calculation, I used basic PBR lighting mode, two texture  used to control the roughness of the iris area and the white area respectively.

For the moisture sensation around the eyes, normal GGX highlights can be used to calculate, mainly to make the eyes look more moist，you can see the diffurence below

![Eye5](https://user-images.githubusercontent.com/56297955/178556358-2f96e0a1-4023-42e7-8158-7aec9c125e8b.png)

![Eye6](https://user-images.githubusercontent.com/56297955/178556373-2e4cc398-2413-4ba7-b038-de460bdd9d04.png)
