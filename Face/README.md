## Face rendering 

### Main rendering methods

How to calculate diffuse : normal diffuse + SSS + ambient

How to calculate specular : Dual Lobe Specular / Kelemen(Szirmay-Kalos) specular BRDF

How to calculate transmittance : sample thickness texture 

How to calculate AO : sample AO texture

### Detail methods
Do the cavity specular ao

Do multi diffuse texture

#### Grease layer
GGX Specular or sample Beckmann tetxture to get specular.GGX is normal and I only show the Keleman specular. In contrast, it has a more oily feel.In  GPU Gems3 they described the algorithm in detail.


![image](https://user-images.githubusercontent.com/56297955/178638997-84185612-4f2b-4e9d-8f9f-a779fbb1335b.png)


![Face5](https://user-images.githubusercontent.com/56297955/178561192-cf5c5f4a-83a0-4ce1-8301-ac0928424416.png)


#### Specular

![image](https://user-images.githubusercontent.com/56297955/178639339-e9ea6492-7db5-474e-83c9-6a14e10cafb5.png)

And other highlights different calculations, the skin is a multilayer structure, the bottom of the oil layer also highlights for contribution, so now the common technique is to do two highlights calculation, and the use of different roughness map, main highlight contribution using high frequency calculation, the secondary highlights contribution using low frequency calculation, and then according to the proportion of additive, According to Next Studio's technique, the visual performance of the shared three - and four-layer and two-layer highlights is almost indistinguishable.


![Mat](https://user-images.githubusercontent.com/56297955/178640035-8f77f2eb-4ec4-4897-99bb-35ab0cfcd272.png)


https://user-images.githubusercontent.com/56297955/178640384-8795721d-d46e-4ad6-bf3e-b3f17a184a23.mp4


#### SSS

To calculate SSS, I tried Pre-integration algrithmn, and I think it is already good.It is a look-up table algrithmn, in this table, the results of secondary surface scattering are stored in a table, and the secondary surface scattering values of colored points are checked through NdotL and curvature of the model.


https://user-images.githubusercontent.com/56297955/179366675-da1d3973-8096-4b07-a386-f35e0261a74f.mp4

