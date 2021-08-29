--vim: filetype=lua ts=2 sw=2 sts=2 et :

return {
   synopsis = [[
 ,-_|\   keys
/     \  (c) Tim Menzies, 2021, unlicense.org
\_,-._*  Cluster, then report just the 
     v   deltas between nearby clusters.  ]],
   usage    = "./keys",
   author   = "Tim Menzies",
   copyright= "(c) Tim Menzies, 2021, unlicense.org",
   options  = {
        bins= { .5    ,'Bins are of size n**BINS'},
        bootstrap={512,'number of bootstrap samples'},
        cols= {'x'    ,'Columns to use for inference'},
        conf=  {0.05,   "confidence for bootstraps"},
        cliffs={ .147 ,"small effect "},
        data= {'../data/auto2.csv' 
                      ,'Where to read data'},
        eg=   {""     ,"'-x ls' lists all, '-x all' runs all"},
        far=  { .9    ,'Where to look for far things'},
        goaL= {'best' ,'Learning goals: best|rest|other'},
        iota= { .3    ,'Small = sd**iota'},
        k=    {2      ,'Bayes low class frequency hack'},
        knn=  {2      ,'Number of neighbors for knn'},
        kadd= {"mode", "combination rule of knn"},
        loud= {false  ,'Set verbose'},
        m=    {1      ,'Bayes low range frequency hack'},
        p=    {2      ,'Distance calculation exponent'},
        sames={256    ,"max size of nonparametric samples"},
        some= {20     ,'Number of samples to find far things'},
        seed= {10013  ,'Seed for random numbers'},
        top=  {10     ,'Focus on this many'},
        wild= {false  ,'Run egs, no protection (wild mode)'},
        wait= {10     ,'Pause before thinking'}}}
