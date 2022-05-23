
%% Visió per Computador Projecte
%
%
clear, clc

%% Carreguem imatges
%
%



path = ("./img.jpg");
imatge=imresize(imread(path),[240,320]);

%%
test = imatge;


%% Detector de contorns
%
%
gray = rgb2gray(test);
edged = edge(gray,'canny');



%%

newimg = uint8(edged);
newimg = 255.*newimg;

mask = strel("rectangle",[21,21]);
closed = imerode(imdilate(newimg, mask), mask);
closedEdge = edge(closed,'canny');
%% Gaussian surface mesh
ts = min(size(closedEdge));

RedundanceWeight = ts;
EdgeWeight = 75;
EWidth = 3.5;
RWidth = 1.5;

x=linspace(-RWidth, RWidth, RedundanceWeight);
y=x;
[X,Y]=meshgrid(x,y);
z=(1.*exp(-(X.^2/2)-(Y.^2/2)));
RedundanceInfluence = z;

x=linspace(-EWidth, EWidth, EdgeWeight);
y=x;
[X,Y]=meshgrid(x,y);
EdgeInfluence =(1.*exp(-(X.^2/2)-(Y.^2/2)));

%%
HeatmapEdge = double(zeros(size(closedEdge)));
[sy,sx]=size(HeatmapEdge);
for i=1:sy;
    for j=1:sx;
        if (closedEdge(i,j) ~= 0)
            for k=1:EdgeWeight
                tk=k-int32(EdgeWeight/2);
                for l=1:EdgeWeight
                    tl=l-int32(EdgeWeight/2);
                    cutX = j+tl;
                    cutY = i+tk;
                    if(cutY < 1)
                        cutY = 1;
                    end
                    if(cutY > sy)
                        cutY = sy;
                    end
                    if(cutX < 1)
                        cutX = 1;
                    end
                    if(cutX > sx)
                        cutX = sx;
                    end
                    remap = max(HeatmapEdge(cutY,cutX),EdgeInfluence(k,l));
                    HeatmapEdge(cutY,cutX) = remap;
                end
            end
        end
    end
end

HeatmapRedundance = double(zeros(size(closedEdge)));
offset = int32(RedundanceWeight/2);
pad = int32(size(closedEdge))/2 - offset;

            for k=1:RedundanceWeight
                tk=k-offset;
                for l=1:RedundanceWeight
                    tl=l-offset;
                    cutX = offset+tl;
                    cutY = offset+tk;
                    if(cutY < 1)
                        cutY = 1;
                    end
                    if(cutY > sy)
                        cutY = sy;
                    end
                    if(cutX < 1)
                        cutX = 1;
                    end
                    if(cutX > sx)
                        cutX = sx;
                    end
                    
                    remap = max(HeatmapRedundance(pad(1)+cutY,pad(2)+cutX),RedundanceInfluence(k,l));
                    HeatmapRedundance(pad(1)+cutY,pad(2)+cutX) = remap;
                end
            end
%%
HeatmapRedundance =imgaussfilt(HeatmapRedundance,20);
FinalHeatmap=(HeatmapEdge+(HeatmapRedundance))/2;
Output = zeros(500,1);
OutputX = zeros(500,1);
OutputY = zeros(500,1);

for i=1:2501;
    randX=randi(sx);
    randY=randi(sy);
    
    


    if(min(Output)<FinalHeatmap(randY,randX))
        [Output,sortIdx] = sort(Output,'ascend');
        OutputX = OutputX(sortIdx);
        OutputY = OutputY(sortIdx);
        Output(1) = FinalHeatmap(randY,randX);
        OutputX(1) = randX;
        OutputY(1) = randY;
    end
end



fileID = fopen('XYCoord.txt','w');
for i = 1:size(OutputX)
    fprintf(fileID,'%d , %d \n',OutputX(i),OutputY(i));
end
fclose(fileID);
