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


![image](https://user-images.githubusercontent.com/56297955/178638948-3dc9348d-77b8-47e7-acca-b3614e598d3b.png)


![Face5](https://user-images.githubusercontent.com/56297955/178561192-cf5c5f4a-83a0-4ce1-8301-ac0928424416.png)
