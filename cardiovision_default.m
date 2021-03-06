clear all
close all
dt = 0.0001; %s
%inital values
LVP(1) = 8.2; %mmHgLAP, left ventricular pressure
LAP(1) = 7.6; %mmHg, left atrial pressure
AP(1) = 67; %mmHg, arterial pressure
AOP(1) = 80; %mmHg, aortic pressure
Qa(1) = 0; %ml/s, aortic valve flow rate

Cv(1) = 0;
t = 0;

X(:,1) = [LVP(1);LAP(1);AP(1);AOP(1);Qa(1)];

%constants
HR = 60; %beats/min
tc = 60/HR; %amount of time in 1 cardiac cycle (in sec)
Tmax = 0.2 + 0.15*tc; %time when Emax occurs
Rs = 1; %mmHgs/ml  Systemic Vascular Resistance
Rm = 0.0050; %mmHgs/ml Mitral Valve REsistance
Ra = 0.0010; %mmHgs/ml Aortic Valve Resistance
Rc = 0.0398; %mmHgs/ml Characteristic Resistance
Cr = 4.4000; %ml/mmHg Left atrial Compliance
Cs = 1.3300; %ml/mmHg Systemic Compliance
Ca = 0.0800; %ml/mmHg Aortic Compliance
Ls = 0.0005; %mmHgs^2/ml Inertance of blood in aorta
Emax = 2;
Emin = .06;
V0 = 10; %ml

i=0;
tn = 0;
Time(1) = t;
while t<=tc %within 1 cardiac cycle
    i = i + 1;
    tn = (t-floor(t))/Tmax; %tn=t/Tmax
    En = 1.55*(((tn/0.7)^1.9)./(1+(tn/0.7)^1.9))*(1/(1+(tn/1.17)^21.9));
    %normalized elastance w double hill
    E(i) = (Emax - Emin)*En+Emin;
    LVV(i) = X(1,i)./E(i) + V0; %comes from E=LVP/(LVV+V0)
    Cv(i) = 1/E(i); %compliance vs elastance relationship
    if (X(2,i) - X(1,i))>0 %LAP>LVP
        Dm = 1; %blood flow thru mitral valve
    else
        Dm = 0; %no blood flow thru mitral valve
    end
    if (X(1,i)-X(4,i))>0 %LVP>AOP
        Da = 1; %blood flow thru aortic valve
    else
        Da = 0; %no blood flow thru aortic valve
    end
    if i>1 %always?
        dCv = (Cv(i)-Cv(i-1))/dt;
    else
        dCv = 0;
    end
    A = [-dCv/Cv(i),0,0,0,0;
        0,-1/(Rs*Cr),1/(Rs*Cr),0,0;
        0,1/(Rs*Cs),-1/(Rs*Cs),0,1/Cs;
        0,0,0,0,-1/Ca;
        0,0,-1/Ls,1/Ls,-Rc/Ls];
    B = [1/Cv(i),-1/Cv(i);
        -1/Cr,0;
        0,0;
        0,1/Ca;
        0,0];
    C = [(X(2,i) - X(1,i))*Dm/Rm;
        (X(1,i) - X(4,i))*Da/Ra];
    
    dx = A*X(:,i)+B*C;
    X(:,i+1) = X(:,i) + dx.*dt;
    t = t + dt;
    Time(i+1) = t;
end
 i = i + 1;
    tn = (t-floor(t))/Tmax;
    En = 1.55*(((tn/0.7)^1.9)./(1+(tn/0.7)^1.9))*(1/(1+(tn/1.17)^21.9));
    E(i) = (Emax - Emin)*En+Emin;
    LVV(i) = X(1,i)/E(i) + V0;
    
plot(Time,X(1,:))
hold on
%figure
plot(Time,X(2,:))
%figure
plot(Time,X(3,:))
%figure
plot(Time,X(4,:))
legend('LVP','LAP','AP','AOP')
xlabel 'Time [s]';
ylabel 'Pressure [mmHg]';
figure
plot(Time,X(5,:))
legend('Qa')
xlabel 'Time [s]';
ylabel 'Flow rate [ml/s]';
figure
plot(LVV,X(1,:))
legend('LVP vs. LVV')
xlabel 'Volume [ml]';
ylabel 'Pressure [mmHg]';