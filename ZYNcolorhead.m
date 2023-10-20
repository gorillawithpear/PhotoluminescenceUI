cmap = cbrewer('div','RdBu',256);
cmap(cmap<0)=0;
cmap(cmap>1)=1;
cmap = flip(cmap);
datarange = 460:1200;