%%%%%  QRS Detection Using Dynamic Plosion Index  %%%%%
clc
clear
close all

y=csvread('D:\ECG\ECG data\mit_bih_100.csv');   %Input data file
fs=400; %Sampling Rate
time=4; %Time interval
tint=time*fs;   %No. of sample in time interval
run=1;

x=y(run:run+tint);

%Removing DC value
avg=0;
for i=1:length(x)
    avg=avg+x(i);
end
avg=avg/length(x);
x=x-avg;

subplot 311;    %Plot Input ECG signal
plot(x);
xlim([0 tint]);
title('Input ECG signal');
xlabel('Samples -->');
ylabel('Amplitude -->');

z=tf('z',400);

%HPF
[b1,a1] = butter(1,5/200,'high');
y1=filter(b1,a1,x);
y1=wrev(y1);
y2=filter(b1,a1,y1);
y2=wrev(y2);

%LPF
[b2,a2] = butter(1,15/200,'low');
y3=filter(b2,a2,y2);
y3=wrev(y3);
y4=filter(b2,a2,y3);
y4=wrev(y4);
% subplot 312;
% plot(y4);

%Derivative
H=0.1*(2+z^-1-z^-3-2*z^-4);
[b3,a3]=tfdata(H,'v');
y5=filter(b3,a3,y4);
y5=wrev(y5);
y6=filter(b3,a3,y5);
y6=wrev(y6);
% subplot 312;
% plot(y5);

%Squaring
y7=y6.^2;
% subplot 312;
% plot(y7);

%Moving-window integrator
b4=ones(1,60);
a4=60;
y8=filter(b4,a4,y7);
y8=wrev(y8);
y9=filter(b4,a4,y8);
y9=wrev(y9);
subplot 312;
plot(y9);
xlim([0 tint]);
title('Filtered ECG signal');
xlabel('Samples -->');
ylabel('Amplitude -->');
x=y9;

% max1=max(x);
% x = padarray(x,100,0.01*max1);
% x=x(1:end-201);
% subplot 312;
% plot(x);

ind = find(x);
savg=0;

% n0(1)=1;
diffloc=zeros(1,5);


ind1=1;
ind2=1;
n0 = ones(1,ceil(time*225/60));
n0(1)=ind(1);
while(ind1<=ceil(time*225/60) && n0(ind2)<tint-110)
m=0;
pi=zeros(1,end);
if n0(ind2)<5
    m1=-n0(ind2);
else
    m1=-5;
end
for m2=1:tint-(n0(ind2)+m1)
    for i=n0(ind2)+m1+1:n0(ind2)+m1+m2
        savg = savg + x(i);
    end
    savg = savg/(m2^(1/2));
    if savg==0
        pi(m+n0(ind2))=0;
    else
        pi(m+n0(ind2)) = x(n0(ind2))/savg;
    end
    savg=0;
    m=m+1;
end
subplot 313;
plot(pi);
    xlim([0 tint]);
title('DPI');
xlabel('Samples -->');
ylabel('Amplitude -->');
diff1=0;
if ind1==1
    chk=10;
else
    chk=110;
end
for i=n0(ind2)+chk:tint-1
    %         if i==n0+chk
    %         else
    if pi(i)>pi(i+1) & pi(i)>pi(i-1)
        max1=pi(i);
        maxloc=i;
        flag=1;
    end
    if pi(i)<pi(i+1) & pi(i)<pi(i-1)  %#ok<*AND2>
        if flag==1
            min1=pi(i);
            minloc=i;
            flag=2;
        end
    end
    if flag==2
        temp=max1-min1;
        %                       fprintf('%d - %f\n',maxloc,temp);
        if temp>diff1
            diff1=temp;
            %                             fprintf('%f\n',diff1);
            diffloc(ind1)=(maxloc+minloc)/2;
            %                        fprintf('%f\n',diffloc(in));
        end
        flag=0;
    end
    %         end
end
if ind1==1
    temp2=diff1;
end
%     fprintf(' prev - %f\n',temp2);
if diff1>0.3*temp2
    ind2=ind2+1;
    n0(ind2)=round(diffloc(ind1));
%             fprintf('n0 = %d\n',n0);
    if n0(ind2)>100 && ind1==1
        max1=0;
        for k=1:300
            if x(k)>max1
                max1=x(k);
                n0(ind2)=k;
            end
        end
    end
    temp2=diff1;
    fprintf('Heart beat detected at sample = %d\n',n0(ind2));
end

pause(0.001);
ind1=ind1+1;
end
n0=n0.*(n0>1);
ind=find(n0);
n0=n0(ind);
hr=60./(diff(n0)/fs);
avghr = sum(hr)/numel(hr);
fprintf('Instantaneous Heart Rate = %f\n',hr);
fprintf('\nAverage Heart Rate  = %f\n',avghr);
