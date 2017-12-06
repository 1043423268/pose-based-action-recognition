# pose-based-action-recognition
Human Action Recognition Based on Pose Spatio-Temporal Features

Firstly, with the joint positions of human body in each frame of the video acquired, we extracted pose information by handcrafted features. Specifically, the positions of joints and relatives in the spatial dimension, as well as the change of that in the temporal dimension were calculated. The two together constituted human pose spatiotemporal feature descriptors. 
Then the Fisher Vector model was utilized to compute fixed dimension Fisher vector for each descriptor separately. 
Lastly, features were weighted to fusion for classification. Experimental results show that the proposed algorithm can effectively improve action recognition performance.
