clear , 
close all, 
clc
%%
ub=[5;5;5;0.5];  
lb=[0;0;0;0.01];
nvars=4;
PopSize = 20;
MaxGenerations = 50;

A=[-1 1 0 0
    1 0 -1 0];
b=zeros(2,1);
options = optimoptions(@ga,'PopulationSize',PopSize,'MaxGenerations',MaxGenerations,'PopulationType','doubleVector','Display','iter');
%options = optimoptions(@ga,'Display','final');
[x,fval,exitflag,output,population,scores] = ga(@(K_pid)optifun(K_pid),...
                                             nvars,A,b,[],[],lb,ub,[],options);
                                         
%%
for i=1:PopSize
    plotting(population(i,:));
end

%%
plotting_final(x)
                                         

