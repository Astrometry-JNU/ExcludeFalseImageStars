function cout = cpdaSimp(BW)

I = BW;
EP = 0;

% Extract curves from the edge-image
[curve,curve_start,curve_end,curve_mode,curve_num,TJ,img1] = extract_curve(BW);  
% curve         : MATLAB cell data structure where each cell is a 2D array containing
%               pixel locations (x and y values)
% curve_start   : starting points of extracted curves
% curve_end     : ending points of extracted curves
% curve_mode    : two curve modes - 'line' and 'loop'. If the both ends of
%               a curve are at maximum 25 square pixels (default) away, then the
%               curve is a loop curve, otherwise a line curve
% curve_num     : number of extracted curves
% TJ            : the T-junction found in the edge-extraction process
% img1          : output image containing the extracted edges

[sizex sizey] = size(I);
if size(curve{1})>0
    % Detect corners on the extracted edges
    [corner_out index Sig cd2] = getcorner(curve,curve_mode,curve_start,curve_num,sizex,sizey); 
    
    % corner_out	: n by 2 matrix containing the positions of the
    %               detected corners, where n is the number of detected
    %               corners
    % index         : MATLAB cell data structure where each cell is an 1D
    %               column matrix contaning the edge pixel numbers (in curve) where
    %               the corners are detected
    % Sig           : the sigma values used to smooth the curves
    % cd2           : cpda curvature values of the detected corners
    
    % Update the T-junctions
    [corner_final cd3] = Refine_TJunctions(corner_out,TJ,cd2,curve, curve_num, curve_start, curve_end, curve_mode,EP);
    % corner_final  : n by 2 matrix containing the positions of the
    %               detected corners, where n is the number of detected
    %               corners
    % cd3           : cpda curvature values of the detected corners

    %figure(); imshow(marked_img);
     %imwrite(marked_img,'acclaim002_cpda_corner.bmp','BMP');
    cout = corner_final;
    cd = cd3;
else
    cout = [];
    marked_img = [];
    cd = [];
end

here = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [corners,index,Sig,cd] = getcorner(curve,curve_mode,curve_start,curve_num,sizex,sizey)

corners = [];
cor = []; % candidate corners
cd = [];
T_angle = 157;
CLen = [10 20 30];
T = 0.2; % define the curvature threshold
sig = 3.0;
[gau, W] = makeGFilter(sig);
for i=1:curve_num;
    C = []; C3 = [];
    x = curve{i}(:,2) - sizey/2;
    y = sizex/2 - curve{i}(:,1);
    curveLen = size(x,1);    
    [xs ys W] = smoothing(x,y,curveLen,curve_mode(i,:),gau,W); % smooth the curve with Gaussian kernel
    if size(xs,1)>1   
        if curve_mode(i,:)=='loop'
            xs1=[xs(curveLen-W+1:curveLen);xs;xs(1:W)];
            ys1=[ys(curveLen-W+1:curveLen);ys;ys(1:W)];
        else %expand the ends to gaussian window
            xs1=[ones(W,1)*2*xs(1)-xs(W+1:-1:2);xs;ones(W,1)*2*xs(curveLen)-xs(curveLen-1:-1:curveLen-W)];
            ys1=[ones(W,1)*2*ys(1)-ys(W+1:-1:2);ys;ones(W,1)*2*ys(curveLen)-ys(curveLen-1:-1:curveLen-W)];
        end   
        xs = xs1;
        ys = ys1;
        L = curveLen+2*W;   
        for j = 1:3
            chordLen = CLen(1,j);
            C3(j,1:L) = abs(accumulate_chord_distance(xs,ys,chordLen,L));
        end
        c1 = C3(1,W+1:curveLen+W)/max(C3(1,W+1:curveLen+W));
        c2 = C3(2,W+1:curveLen+W)/max(C3(2,W+1:curveLen+W));
        c3 = C3(3,W+1:curveLen+W)/max(C3(3,W+1:curveLen+W));

        C = c1.*c2.*c3;    
        L = curveLen;
        xs = xs(W+1:L+W);
        ys = ys(W+1:L+W);

        % Find curvature local maxima as corner candidates
        extremum=[];
        N=size(C,2);
        n=0;
        Search=1;

        for j=1:N-1
            if (C(j+1)-C(j))*Search>0
                n=n+1;
                extremum(n)=j;  % In extremum, odd points are minima and even points are maxima
                Search=-Search; % minima: when K starts to go up; maxima: when K starts to go down 
            end
        end
        if mod(size(extremum,2),2)==0 %to make odd number of extrema
            n=n+1;
            extremum(n)=N;
        end

        %%% accumulate candidate corners
        n = size(extremum,2);    
        for j = 1:n
            cor = [cor; curve{i}(extremum(j),:)];  
        end   
        %%%

        n = size(extremum,2);
        flag = ones(size(extremum));

        % Compare each maxima with its contour average
        for j=2:2:n % if the maxima is less than local minima, remove it as flase corner
            if (C(extremum(j)) > T)
                flag(j)=0;
            end
        end
        extremum = extremum(2:2:n); % only maxima are corners, not minima
        flag = flag(2:2:n);
        extremum = extremum(find(flag==0));    

        % Check corner angle to remove false corners due to boundary noise and trivial details
        %fl = 0;
        %if fl
        flag=0;
        smoothed_curve=[xs,ys];
        while sum(flag==0)>0
            n=size(extremum,2);
            flag=ones(size(extremum)); 
            for j=1:n % second argument of curve_tangent function is always the position of the extrema in the first argument
                %which is array of points between two exterama
                if j==1 && j==n
                    ang=curve_tangent(smoothed_curve(1:L,:),extremum(j));
                elseif j==1 
                    ang=curve_tangent(smoothed_curve(1:extremum(j+1),:),extremum(j));
                elseif j==n
                    ang=curve_tangent(smoothed_curve(extremum(j-1):L,:),extremum(j)-extremum(j-1)+1);
                else
                    ang=curve_tangent(smoothed_curve(extremum(j-1):extremum(j+1),:),extremum(j)-extremum(j-1)+1);
                end     
                if ang>T_angle && ang<(360-T_angle) % if angle is between T_angle = 162 and (360-T_angle) = 198
                    flag(j)=0;  
                end
            end

            if size(extremum,2)==0
                extremum=[];            
            else
                extremum=extremum(find(flag~=0));             
            end
        end   
        extremum=extremum(find(extremum>0 & extremum<=curveLen)); % find corners which are not endpoints of the curve             
        index{i} = extremum';
        Sig(i,1) = sig;
        n = size(extremum,2);
        for j = 1:n
            corners = [corners; curve{i}(extremum(j),:)];
            cd = [cd; C(extremum(j))];
        end    

        if curve_mode(i,:)=='loop'       
            if n>1
                compare_corner=corners-ones(size(corners,1),1)*curve_start(i,:);
                compare_corner=compare_corner.^2;
                compare_corner=compare_corner(:,1)+compare_corner(:,2);
                if min(compare_corner)>100       % Add end points far from detected corners, i.e. outside of 5 by 5 neighbor                                                
                    left = smoothed_curve(extremum(1):-1:1,:);
                    right = smoothed_curve(end:-1:extremum(end),:);
                    ang=curve_tangent([left;right],extremum(1)); % detect corner at the first point or last point of the loop curve
                    if ang>T_angle && ang<(360-T_angle) % if angle is between T_angle = 162 and (360-T_angle) = 198                

                    else%if C(W+1)>T/2
                        corners = [corners; curve_start(i,:)];
                        cd = [cd;5];
                    end
                end
            end
        end
    end
end


        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Cd = accumulate_chord_distance(xs,ys,chordLen,curveLen)

Cd = zeros(1,curveLen);

for k = 2:curveLen-1
    xk = xs(k); % (x1,y1) = point at which distance will be accumulated
    yk = ys(k);      
        
    if k-chordLen+1 < 1
        s = 1;
    else
        s = k-chordLen+1;
    end
                
    for i = s:k-1
        if i+chordLen <= curveLen
            x1 = xs(i); % (leftx,lefty) = current left point for which distance will be accumulated
            y1 = ys(i); 

            x2 = xs(i+chordLen); % (rightx,righty) = current right point for which distance will be accumulated
            y2 = ys(i+chordLen);

            a = y2-y1; % coefficients of st. line through points (x1,y1) and (x2,y2)
            b = x1-x2;
            c = x2*y1 - x1*y2;
            dist = (a*xk + b*yk + c)/sqrt(a*a+b*b);
            Cd(1,k) = Cd(1,k)+ dist;
        else
            break;
        end
    end
end

%%%%%%%%%%%55
function [xse yse] = enlarge(xs,ys,CL,curve_mode);
%CL = chord length
L = size(xs,1);
if curve_mode=='loop' % wrap around the curve by CL pixles at both ends
    xse = [xs(L-CL+1:L);xs;xs(1:CL)];
    yse = [ys(L-CL+1:L);ys;ys(1:CL)];
else % extend each line curve by CL pixels at both ends
    xse = [ones(CL,1)*2*xs(1)-xs(CL+1:-1:2);xs;ones(CL,1)*2*xs(L)-xs(L-1:-1:L-CL)];
    yse = [ones(CL,1)*2*ys(1)-ys(CL+1:-1:2);ys;ones(CL,1)*2*ys(L)-ys(L-1:-1:L-CL)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%
function [xs, ys, W] = smoothing(x,y,L,curve_mode,gau,W)

if L>W
    if curve_mode=='loop' % wrap around the curve by W pixles at both ends
        x1 = [x(L-W+1:L);x;x(1:W)];
        y1 = [y(L-W+1:L);y;y(1:W)];
    else % extend each line curve by W pixels at both ends
        x1 = [ones(W,1)*2*x(1)-x(W+1:-1:2);x;ones(W,1)*2*x(L)-x(L-1:-1:L-W)];
        y1 = [ones(W,1)*2*y(1)-y(W+1:-1:2);y;ones(W,1)*2*y(L)-y(L-1:-1:L-W)];
    end
    
    xx=conv(x1,gau);
    xs=xx(2*W+1:L+2*W);
    yy=conv(y1,gau);
    ys=yy(2*W+1:L+2*W);    
else
    xs = [];
    ys = [];    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract curves from input edge-image
function [curve,curve_start,curve_end,curve_mode,cur_num,TJ,img]=extract_curve(BW)
%   Function to extract curves from binary edge map, if the endpoint of a
%   contour is nearly connected to another endpoint, fill the gap and continue
%   the extraction. The default gap size is 1 pixel
[L,W]=size(BW);
BW1=zeros(L+2,W+2);
BW_edge=zeros(L,W);
BW1(2:1+L,2:1+W)=BW;
[r,c]=find(BW1==1); %returns indices of non-zero elements
cur_num=0;

while size(r,1)>0 %when number of rows > 0
    point=[r(1),c(1)];
    cur=point;
    BW1(point(1),point(2))=0; %make the pixel black
    [I,J]=find(BW1(point(1)-1:point(1)+1,point(2)-1:point(2)+1)==1); 
                               %find if any pixel around the current point is an edge pixel
    while size(I,1)>0 %if number of row > 0
        dist=(I-2).^2+(J-2).^2;
        [min_dist,index]=min(dist);
        p=point+[I(index),J(index)];
        point = p-2; % next is the current point
        cur=[cur;point]; %add point to curve 
        BW1(point(1),point(2))=0;%make the pixel black
        [I,J]=find(BW1(point(1)-1:point(1)+1,point(2)-1:point(2)+1)==1);
                                %find if any pixel around the current point 
                                %is an edge pixel
    end
    
    % Extract edge towards another direction
    point=[r(1),c(1)];
    BW1(point(1),point(2))=0;
    [I,J]=find(BW1(point(1)-1:point(1)+1,point(2)-1:point(2)+1)==1);
    
    while size(I,1)>0
        dist=(I-2).^2+(J-2).^2;
        [min_dist,index]=min(dist);
        point=point+[I(index),J(index)]-2;
        cur=[point;cur];
        BW1(point(1),point(2))=0;
        [I,J]=find(BW1(point(1)-1:point(1)+1,point(2)-1:point(2)+1)==1);
    end
        
    if size(cur,1)>(size(BW,1)+size(BW,2))/25 % for 512 by 512 image, choose curve if its length > 40
        cur_num=cur_num+1;                    % One can change this value to control the length of the extracted edges
        curve{cur_num}=cur-1;
    end
    [r,c]=find(BW1==1);
    
end

for i=1:cur_num
    curve_start(i,:)=curve{i}(1,:);
    curve_end(i,:)=curve{i}(size(curve{i},1),:);
    if (curve_start(i,1)-curve_end(i,1))^2+...
        (curve_start(i,2)-curve_end(i,2))^2<=25  %if curve's ends are within sqrt(32) pixels
        curve_mode(i,:)='loop';
    else
        curve_mode(i,:)='line';
    end
    BW_edge(curve{i}(:,1)+(curve{i}(:,2)-1)*L)=1;
end
%%%
TJ = [];
if cur_num == 0
    curve{1} = [];
    curve_start = [];
    curve_end = [];
    curve_mode = [];
    cur_num = [];
    TJ = [];
end
%%%
img=~BW_edge;
%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Compare T-junctions with obtained corners and add T-junctions to corners
% which are far away (outside a 5 by 5 neighborhood) from detected corners
function [corner_final c3] = Refine_TJunctions(corner_out,TJ,c2,curve, curve_num, curve_start, curve_end, curve_mode,EP);
%corner_final = corner_out;
c3=c2;

%%%%%Add T-junctions
corner_final = corner_out;
for i=1:size(TJ,1)
    % T-junctions compared with detected corners
    if size(corner_final)>0
        compare_corner=corner_final-ones(size(corner_final,1),1)*TJ(i,:);
        compare_corner=compare_corner.^2;
        compare_corner=compare_corner(:,1)+compare_corner(:,2);
        if min(compare_corner)>100       % Add end points far from detected corners, i.e. outside of 5 by 5 neighbor
            corner_final = [corner_final; TJ(i,:)];
            c3 = [c3;10];
        end
    else
        corner_final = [corner_final; TJ(i,:)];
        c3 = [c3;10];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% show corners into the output images or into the edge-image
function img1=mark(img,x,y,w)
[M,N,C]=size(img);
img1=img;
if isa(img,'logical')
    img1(max(1,x-floor(w/2)):min(M,x+floor(w/2)),max(1,y-floor(w/2)):min(N,y+floor(w/2)),:)=...
        (img1(max(1,x-floor(w/2)):min(M,x+floor(w/2)),max(1,y-floor(w/2)):min(N,y+floor(w/2)),:)<1);
    img1(x-floor(w/2)+1:x+floor(w/2)-1,y-floor(w/2)+1:y+floor(w/2)-1,:)=...
        img(x-floor(w/2)+1:x+floor(w/2)-1,y-floor(w/2)+1:y+floor(w/2)-1,:);
else
    img1(max(1,x-floor(w/2)):min(M,x+floor(w/2)),max(1,y-floor(w/2)):min(N,y+floor(w/2)),:)=...
        (img1(max(1,x-floor(w/2)):min(M,x+floor(w/2)),max(1,y-floor(w/2)):min(N,y+floor(w/2)),:)<128)*255;
    img1(x-floor(w/2)+1:x+floor(w/2)-1,y-floor(w/2)+1:y+floor(w/2)-1,:)=...
        img(x-floor(w/2)+1:x+floor(w/2)-1,y-floor(w/2)+1:y+floor(w/2)-1,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%
function ang=curve_tangent(cur,center) % center is always the position of the corresponding extrema in cur

for i=1:2
    if i==1
        curve=cur(center:-1:1,:);
    else
        curve=cur(center:size(cur,1),:);
    end
    L=size(curve,1);
    
    if L>3
        if sum(curve(1,:)~=curve(L,:))~=0 % if not collinear
            M=ceil(L/2);
            x1=curve(1,1);
            y1=curve(1,2);
            x2=curve(M,1);
            y2=curve(M,2);
            x3=curve(L,1);
            y3=curve(L,2);
        else
            M1=ceil(L/3);
            M2=ceil(2*L/3);
            x1=curve(1,1);
            y1=curve(1,2);
            x2=curve(M1,1);
            y2=curve(M1,2);
            x3=curve(M2,1);
            y3=curve(M2,2);
        end
        
        if abs((x1-x2)*(y1-y3)-(x1-x3)*(y1-y2))<1e-8  % straight line
            tangent_direction=angle(complex(curve(L,1)-curve(1,1),curve(L,2)-curve(1,2)));
        else
            % Fit a circle 
            x0 = 1/2*(-y1*x2^2+y3*x2^2-y3*y1^2-y3*x1^2-y2*y3^2+x3^2*y1+y2*y1^2-y2*x3^2-y2^2*y1+y2*x1^2+y3^2*y1+y2^2*y3)/(-y1*x2+y1*x3+y3*x2+x1*y2-x1*y3-x3*y2);
            y0 = -1/2*(x1^2*x2-x1^2*x3+y1^2*x2-y1^2*x3+x1*x3^2-x1*x2^2-x3^2*x2-y3^2*x2+x3*y2^2+x1*y3^2-x1*y2^2+x3*x2^2)/(-y1*x2+y1*x3+y3*x2+x1*y2-x1*y3-x3*y2);
            % R = (x0-x1)^2+(y0-y1)^2;

            radius_direction=angle(complex(x0-x1,y0-y1));
            if radius_direction<0
                radius_direction = 2*pi-abs(radius_direction);
            end
            
            adjacent_direction=angle(complex(x2-x1,y2-y1));
            
            if adjacent_direction<0
                adjacent_direction = 2*pi-abs(adjacent_direction);
            end
            
            tangent_direction=sign(sin(adjacent_direction-radius_direction))*pi/2+radius_direction;
            if tangent_direction<0
                tangent_direction = 2*pi-abs(tangent_direction);
            elseif tangent_direction>2*pi
                tangent_direction = tangent_direction-2*pi;
            end
        end
    
    else % very short line
        tangent_direction=angle(complex(curve(L,1)-curve(1,1),curve(L,2)-curve(1,2)));
    end
    direction(i)=tangent_direction*180/pi;
end
ang=abs(direction(1)-direction(2));
%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [G, W] = makeGFilter(sig)

GaussianDieOff = .0001; 
pw = 1:100;

ssq = sig*sig;
W = max(find(exp(-(pw.*pw)/(2*ssq))>GaussianDieOff));
if isempty(W)
    W = 1;  
end
t = (-W:W);
gau = exp(-(t.*t)/(2*ssq))/(2*pi*ssq); 
G=gau/sum(gau);
