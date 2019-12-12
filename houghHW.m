%reading image and preprocessing 
I = imread('C:\Users\MONSTER\Desktop\hough transform\im01.jpg');
I=rgb2gray(I);
%I=imrotate(I,5); % a slight rotation if it is needed
Ie=edge(I,'canny');

%setting theta and rho values
[H,W]=size(Ie);
N=90;
thetaArray=-N:N-1;
rho_max=floor(sqrt(H^2 + W^2)) - 1;
rhoArray=-rho_max:rho_max;

%creating empty accumulator
hgh=zeros(length(rhoArray),length(thetaArray)+1);

%voting
for y=1:H    
    for x=1:W       
        if(Ie(y,x)==1)
            for t=thetaArray
                %%x.cos()+y.sin()=p                
                rho=round(x*cosd(t)+y*sind(t));
                r_index=rho+rho_max+1;
                t_index=t+N+1;                
                hgh(r_index,t_index)=hgh(r_index,t_index)+1;                            
            end
        end
    end
end

%hough space display
imshow(hgh,[],'XData',thetaArray,'YData',rhoArray,'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;

%setting threshold
thold=ceil(0.3*max(hgh(:)));

%finding maximas/peaks (might not be the most efficient way)
nOP=5; %-- number of peaks, depends on the picture
peakIndexList=zeros(nOP,2);
peakNumberList=zeros(nOP,1);
for i=1:nOP    
    maximum = max(max(hgh));
    [x_max,y_max]=find(hgh==maximum);
    if(hgh(x_max,y_max)>thold)
        peakIndexList(i,1)=x_max;
        peakIndexList(i,2)=y_max;
        peakNumberList(i)=hgh(x_max,y_max);
        hgh(x_max,y_max)=0;
    end
end
for k=1:nOP  
    xx=peakIndexList(k,1);
    yy=peakIndexList(k,2);
    hgh(xx,yy)=peakNumberList(k);
end

%preparing arrays of rho,theta,m and c arrays
rhoL=zeros(nOP,1); thetaL=zeros(nOP,1); mL=zeros(nOP,1); cL=zeros(nOP,1);
    
figure, imshow(I), hold on
for z=1:nOP
    
    %getting rho and theta values from the arrays
    rhoIndex=peakIndexList(z,1);
    thetaIndex=peakIndexList(z,2);    
    rhoL(z)=rhoArray(rhoIndex-1);
    thetaL(z)=thetaArray(thetaIndex);   
    
    %conversion from polar form to slope-intercept form
    mL(z)=-cotd(thetaL(z));
    cL(z)=rhoL(z)*(1/(sind(thetaL(z))));
    
    %setting x range(it is big enough to cover whole picture on the axis )
    x=1:1000;
    
    %drawing directions of detected lines
    plot(x, mL(z)*x+cL(z),'LineWidth',2,'Color','green');
end
