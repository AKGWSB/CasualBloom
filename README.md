# Casual Bloom

High quality bloom effect implement with unity build-in render pipeline，just for study，not enough efficiency

![image-20220607162742746](README.assets/image-20220607162742746.png)

# implement

simply using ping-pong down & up sample to blur the source image，apply tone-mapping and gamma-correct for bloom texture，then mix it to screen

![image-20220607150646846](README.assets/image-20220607150646846.png)

# How to use

Add Bloom.cs script component to Main Camera，adjust some parameter based on you

![image-20220607151146317](README.assets/image-20220607151146317.png)

make any method that cause pixel's luminance over the threshold，then it will generate bloom，for more bigger value，it gonna to have bigger bloom range

![image-20220607151146317](README.assets/ezgif-5-5235913a83.gif)