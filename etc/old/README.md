<img align=right src="https://www.iconexperience.com/_img/v_collection_png/256x256/shadow/keys.png">    

# Keys = cluster, discretize, elites, contrast   

[![DOI](https://zenodo.org/badge/318809834.svg)](https://zenodo.org/badge/latestdoi/318809834)  
![](https://img.shields.io/badge/platform-osx%20,%20linux-orange)    
![](https://img.shields.io/badge/language-lua,bash-blue)  
![](https://img.shields.io/badge/purpose-ai%20,%20se-blueviolet)  
[![Build Status](https://travis-ci.com/timm/keys.svg?branch=main)](https://travis-ci.com/timm/keys)   
![](https://img.shields.io/badge/license-mit-lightgrey)  
[home](http://menzies.us/keys)         :: [lib](http://menzies.us/keys/lib.html) ::
[cols](http://menzies.us/keys/cols.html) :: [tbl](http://menzies.us/keys/tbl.html) ::
[learn](http://menzies.us/keys/learn.html)

This repo is very much a work in progress.
I'm busy writing  into here all the stuff
learned from several years of grad students as well as numerous experiments in different languages.
So come back soon, this could get interesting.

## Keys 101

Repeat the following until happy or bored. 
Useful defaults for this algorithm are C,N,X,Z=20,100,20,2.  

-  Create N pairs of <inputs,outputs>  by either selecting 
     from a database or running a simulator or asking an oracle.  
-  Cluster on the pairs on the output scores into groups of size .5X%. . 
     - If there is only one score, just sort on that one output variable.  
     - Else, cluster the pairs using the output scores with (say) a 
     recursive KMEANS++ algorithm with k=2.   
- Discretize: 
  - Using the clusters, divide the N pairs into  the X% best (B) 
    and Y=100-X% worst (W) outputs.   
  - Use something simple like C% equal percentile chops or Chi-merge 
    to divide numeric inputs into ranges R1, R2, etc.   
- Elite sampling:
  - Take all those ranges, and all the ranges of non-numeric inputs R10,R11,
        etc and count  how often they appear among the best and worst pairs. 
  - Normalize those counts  as follows: #B=#B/(N\*X/100) and #W=#W/(N\*Y/100)
  - Discard unpromising ranges; i.e. if  #W >= #B.    
- Contrast:
  - Sort the remaining ranges by #B^2/(#B+#W) into a list L of size S
  -  Generate N’ new inputs by,  N times, using 
     inputs L[0:max(1,int(S\*rand()<sup>Z</sup>)) (and randomly selected items for everything else).  
     - To create the new output 
       scores either ask some oracle or re-run the simulator (if it exists) or 
       interpolate between nearest neighbors in the database. 
-  Return the final best X% group.


