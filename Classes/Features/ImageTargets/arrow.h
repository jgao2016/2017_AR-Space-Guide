/*
arrowIndex and company names
 things we need to update when changing dataset:
 1 arrow.h
 2 ImageTargetsEAGLView.h -> kNumAugmentationTextures
 3 if we added more logo, we also need to add their model header files
*/

const int logoNum = 8;

const int markNum = 12;

int arrowIndex1D[] = {
    
    //arrowIndex1D[logoIndex][markIndex] = the index of the arrow model to show for this logo at this marker.
    // if index = 1, left arrow; = 2, right arrow; = 3, left-forward arrow; = 4 right-forward arrow
    //if arrow index = 0, show nothing.
    //logoIndex and markIndex starts from 1.
    //logoIndex = 0 is meaningless.
    //logoIndex != 0, markIndex = 0, then it will show the arrow on the logo, leading to the first marker of this path.
    //arrowIndex1D[logoIndex][markIndex]= = -1, meaning this marker is the last marker (destination) of this logo.
  //0  1  2  3  4  5  6  7  8  9  10  11 -markers
    0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,  0,
    1, 1, 1, 4, 3, 1, 1, 1, 1, -1, 0,  0,
    1, 2, 1, 3, 1, 1, 0, 0, 1, 0, 0,  -1,
    1, 4, 1, 0, 0, 0, -1, 0, 1, 0, 0,  0,
    1, 4, 1, 0, 0, 0, -1, 0, 1, 0, 0,  0,
    1, 4, 1, 0, 0, 0, -1, 0, 1, 0, 0,  0,
    1, 4, 1, 0, 0, 0, -1, 0, 1, 0, 0,  0,
    1, 4, 1, 0, 0, 0, -1, 0, 1, 0, 0,  0,
//    0, 0, 0,
//    1, 1, 1,
//    1, 2, 1,
//    1, 1, 1,
//    1, 1, 1,
//    1, 1, 1,
//    1, 1, 1,
//    1, 1, 1,

};
NSString *logoNames[] = {
    @"0",
    @"SpaceFactory",
    @"AI.",
    @"Ridley",
    @"EVBOX",
    @"Homer",
    @"Mattershift",
    @"Connecthings",
};

