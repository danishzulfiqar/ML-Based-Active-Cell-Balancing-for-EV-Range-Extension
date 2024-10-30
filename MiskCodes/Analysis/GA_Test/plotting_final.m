function plotting_final(K_pid)
%%
k=1;b=1;m=1; %system parameters
kp=K_pid(1);ki=K_pid(2);kd=(3);p=K_pid(4); %PID controller parameters

s=tf('s');
G=(1/m)/(s^2+(b/m)*s+k/m);    %plant transfer function
K = kp + ki/s + kd*s/(p*s+1); %PID controller transfer function
MR=2/(s^2+2*s+2);             %Reference model

T=G*K/(1+G*K);                %closed loof T/F: r--> y
KS=K/(1+G*K);                 %closed loop T/F: r--> u  

dt=0.01;                      %step size for time
t=0:dt:10;                    %time vector
u=heaviside(t);               %step function

ycl=lsim(T,u,t);              %output of the closed loop system 
yr=lsim(MR,u,t);              %output of the reference model
u_pid=lsim(KS,u,t);           %control input
e=u'-ycl;                     %error signal given to PID
%%
figure(4);
plot(t,ycl,t,u);
legend('ycl','r','Orientation', 'Horizontal','Location','Best');
hold on
grid on

figure(5)
plot(t,u_pid);
hold on
grid on
end