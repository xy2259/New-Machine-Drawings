%
% Zeeman slower design calculator
% for Bec2 New Machine.
% Aviv Keshet, adapted from Peyman Ahmadi
%

%% Initialization and constants


%clear
%----------------length segment-------------------------------
Delta = 0.1;
Epsilon = 0.01;
%--------------------------------------------------------------
%--------------------Slower Segments--------------------------
% 1 = Decreasing field coil
% 2 = Increasing field coil
% 3 = second part of increasing field coil
% 4 = compensation coil
%----------------Constants-------------------------------------
cm = 1;
mm = 0.1*cm;
inch = 2.54*cm;
mu0 = 4*pi/10;                    %In Gauss-cm/Amp
hbar=1.055*10^(-34);              %J.s

%----------------Coil properties-------------------------------
wire_thickness = (0.1424)*inch;         %new coil dimension in cm
wire_id = wire_thickness - 2*.032*inch;  %Inner diameter of the copper wire
wire_od = wire_thickness;                %Outer diameter of the copper wire
tube_OD = 2.54*cm;                     %Outer diameter
resistivity101 = 1.7*10^-6;       %square tubing
resistivity122 = 2.03*10^-6;      %round tubing
%--------------------------------------------------------------

%------------Atomic Na properties---------------------------------
Lambda = 589*10^(-9);            %Laser light wavelength (m)
mass = 3.82*10^(-26);            %Na mass (Kg)
Gamma = (2*pi)*9.7*10^6;          %Na linewidth (Hz)
vmax=950;                        %Max velocity for oven T of 553 K, m/s
S = 1.5; %Isat = 6.26 mW/cm^2, I = 9.6...
%--------------------------------------------------------------

%------------Atomic Rb properties---------------------------------
%Lambda = 780*10^(-9);            %Laser light wavelength (m)
%mass = (87/23)*3.82*10^(-26);            %Na mass (Kg)
%Gamma = (2*pi)*6*10^6;          %Na linewidth (Hz)
%--------------------------------------------------------------

% H= Mu. B where Mu= e g S /(2 m_e). For Na S for the last electron is
% hbar/2. g for an electron is 2. so Mu becomes, Mu= e hbar/(2 m_e)= Bohr
% Magneton.

Mu = 1.4*10^6;                   %Borh Magneton/h 

%In all of the equations Bohr magneton/hbar appears. So I think Mu should
%be multiplied by a factor of 2*pi. Check it regorously:
%A factor of 1/(2*pi) goes into delta to convert it to a frequency
%A factor of 1/(2*pi) goes into k to make kbar = h/Lambda


%% Desired field

% The zeeman slower is split into several pieces
% 1) a decreasing field slower which starts at some initial field and
% comes down to zero field
% 2) a zero-field "spin flip" region, where the bellows are located
% 3) a increasing field region with the same initial acceleration
% 4) a increasing field region at a lower acceleration


% 1
% * Decreasing field section*
% Theoretical curve (design for a = f*amax)
f = 0.6;
amax = (hbar*(2*pi)/Lambda)/mass*(Gamma/2);    % Maximum acceleration in the slower
detuning = -1000*10^6;                         %Cooling light detuning (negetiv sign is absorbed in B-field Eq)   
Bzero = (detuning+vmax/Lambda)/Mu; %=720.0     %Initial magnetic field at the entrance of the slower     
Bfinal = detuning/Mu;                    %B-field at the end of the slower

% Slower length (not including 0-field gap region (bellows)
len = vmax^2/(2*f*amax);                 %Slower length (m).
len = 100*len;                           %Slower length in cm

%Defining the length variable
z1=0:Delta:len;
Bideal1 =(Bzero - Bfinal)*sqrt(1 - z1./len) + Bfinal;   %B-field Gauss

iDecreasingFieldSection = find(Bideal1>0);
DecreasingFieldSection = Bideal1(iDecreasingFieldSection);

%length(zDecreasingFieldSection)*Delta

% 2
% * Spin flip section *
% (field = zero for some length)

spinFlipLength = 13; %cm
SpinFlipFieldSection=zeros(spinFlipLength/Delta,1);


% 3
% fast increasing section
fastIncreasingLength=20; %cm

iFastIncreasingField = find(Bideal1<0);
iFastIncreasingFieldSection=iFastIncreasingField(1:fastIncreasingLength/Delta);
FastIncreasingFieldSection=Bideal1(iFastIncreasingFieldSection);

% 4 
% slow increasing field section


% Theoretical curve, but designed for a lower acceleration. 
f = 0.4;
amax = (hbar*(2*pi)/Lambda)/mass*(Gamma/2);    % Maximum acceleration in the slower
detuning = -1000*10^6;                         %Cooling light detuning (negetiv sign is absorbed in B-field Eq)   
Bzero = (detuning+vmax/Lambda)/Mu; %=720.0     %Initial magnetic field at the entrance of the slower     
Bfinal = detuning/Mu;                    %B-field at the end of the slower
% Slower length (not including 0-field gap region (bellows)
len = vmax^2/(2*f*amax);                 %Slower length (m).
len = 100*len;                           %Slower length in cm

%Defining the length variable
z1=0:Delta:len;
Bideal2 =(Bzero - Bfinal)*sqrt(1 - z1./len) + Bfinal;   %B-field Gauss


lastvalue = FastIncreasingFieldSection(length(FastIncreasingFieldSection));
iSlowIncreasingFieldSection = find(Bideal2<lastvalue);

SlowIncreasingFieldSection=Bideal2(iSlowIncreasingFieldSection);



DesignFieldProfile=[zeros(100,1);DecreasingFieldSection(:); SpinFlipFieldSection(:); FastIncreasingFieldSection(:); SlowIncreasingFieldSection(:);zeros(100,1)];
z=-100:length(DesignFieldProfile)-1-100;
z=Delta*z;
%plot(z, DesignFieldProfile);
%title('Design Field');
%xlabel('Position (cm)');
%ylabel('Field (G)');



%% Achieved field
AchievedFieldProfile=0;

%bfield1 function format (position z to calculate B field , current through the coil, coil
%diameter, first loop of the coil position, number of turns, wire
%diameter); 


%Coil A

%TurnsA = [135, 121, 107, 93, 77, 61, 43, 25, 15, 8, 0, 0];  %From anand's thesis 
%TurnsA = [132,119, 104, 89, 73, 56, 39, 21, 11, 11, 0, 0];  %Peyman's optimized-by-hand slower design
%TurnsA =  [135,122,107,91,75,57,40,20,12,12,0,0]; Our optimization

%Optimized turns
TurnsA =  [135,122,107,91,75,57,40,20,12,12,0,0];

currentA=15;

for i=1:length(TurnsA)
    AchievedFieldProfile=AchievedFieldProfile+bfield1(z, currentA, tube_OD + (-1+2*i)*wire_thickness, 0, TurnsA(i), wire_thickness);
end

%AchievedFieldProfile=AchievedFieldProfile+bfield1(z, currentA, tube_OD + (-1+2)*wire_thickness, wire_thickness*(TurnsA(1)+1), 2, wire_thickness)
%AchievedFieldProfile=AchievedFieldProfile+bfield1(z, -currentA, tube_OD + (1+2)*wire_thickness, wire_thickness*(TurnsA(1)-3), 2, wire_thickness)

%AchievedFieldProfile=AchievedFieldProfile+bfield1(z, currentA, tube_OD + (-1+2*2)*wire_thickness, wire_thickness*(TurnsA(2)+2), 2, wire_thickness)
%AchievedFieldProfile=AchievedFieldProfile+bfield1(z, -currentA, tube_OD + (1+2*2)*wire_thickness, wire_thickness*(TurnsA(2)-3), 2, wire_thickness)

%for i=3:3
%AchievedFieldProfile=AchievedFieldProfile+bfield1(z, currentA, tube_OD + (-1+2*i)*wire_thickness, wire_thickness*(TurnsA(i)+2), 2, wire_thickness)
%AchievedFieldProfile=AchievedFieldProfile+bfield1(z, -currentA, tube_OD + (1+2*i)*wire_thickness, wire_thickness*(TurnsA(i)-3), 2, wire_thickness)
%end

%AchievedFieldProfile=AchievedFieldProfile+bfield1(z, currentA, tube_OD + (-1+2*9)*wire_thickness, wire_thickness*(TurnsA(10)+2), 2, wire_thickness)
%AchievedFieldProfile=AchievedFieldProfile+bfield1(z, -currentA, tube_OD + (1+2*10)*wire_thickness, wire_thickness*(TurnsA(10)-2), 2, wire_thickness)


%Coil B
%This design uses a few turns of "double-spaced coils".

%TurnsB = [78, 53, 37, 17, 7, 0]; WeakTurnsB=[6,5]; %From Ananth's thesis
%TurnsB = [76, 54, 40, 22, 7, 6]; WeakTurnsB=[7,5]; %Peyman's optimized-by-hand slower design

TurnsB=[76, 54, 40, 22, 7, 6];
WeakTurnsB=[7,5];
currentB=-33.9;
positionB = 100;

for i=1:length(TurnsB)
    AchievedFieldProfile=AchievedFieldProfile + bfield1(z, currentB, tube_OD + (2*i-1) * wire_thickness, positionB, TurnsB(i), -wire_thickness);
    %if (i==3)%((i>2)&(i<5))
  %  AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, currentB, tube_OD + (-1+2*i)*wire_thickness, positionB- (TurnsB(i)+1)*wire_thickness, 2, -wire_thickness)
  %  AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, -currentB, tube_OD + (1+2*i)*wire_thickness, positionB- (TurnsB(i)-2)*wire_thickness, 2, -wire_thickness)
  %  end
end

   % AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, currentB, tube_OD + (-1+2*5)*wire_thickness, positionB- (TurnsB(5)+1)*wire_thickness, 2, -wire_thickness)
   % AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, currentB, tube_OD + (-1+2*6)*wire_thickness, positionB- (TurnsB(6)+2)*wire_thickness, 2, -wire_thickness)
   % AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, -currentB, tube_OD + (1+2*6)*wire_thickness, positionB- (TurnsB(6)-2)*wire_thickness, 2, -wire_thickness)
   % AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, -currentB, tube_OD + (-1+2*6)*wire_thickness, positionB- (TurnsB(6))*wire_thickness, 1, -wire_thickness)
   % AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, -currentB, tube_OD + (1+2*7)*wire_thickness, positionB- (TurnsB(6)-1)*wire_thickness, 1, -wire_thickness)
    
    
for i=1:length(WeakTurnsB)
    AchievedFieldProfile=AchievedFieldProfile + bfield1(z, currentB, tube_OD + (2*i-1) * wire_thickness, positionB - TurnsB(i)*wire_thickness, WeakTurnsB(i), -2*wire_thickness);
end

   
%i=[1];

  
   % AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, +currentB, tube_OD + (-1+2*i)*wire_thickness, positionB-TurnsB(i)*wire_thickness-wire_thickness*(2*WeakTurnsB(i)+1), 1, -wire_thickness)
   % AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, -currentB, tube_OD + (1+2*i)*wire_thickness, positionB-TurnsB(i)*wire_thickness-wire_thickness*(2*WeakTurnsB(i)-2), 1, -wire_thickness)
    

   % AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, +currentB, tube_OD + (1+2*i)*wire_thickness, positionB-(TurnsB(i)+1.5)*wire_thickness, 1, -wire_thickness)
   % AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, -currentB, tube_OD + (1+2*i)*wire_thickness, positionB-(TurnsB(i)-2.5)*wire_thickness, 1, -wire_thickness)
  
    
%i=[2];

  
  %  AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, +currentB, tube_OD + (-1+2*i)*wire_thickness, positionB-TurnsB(i)*wire_thickness-wire_thickness*(2*WeakTurnsB(i)+1), 1, -wire_thickness)
  %  AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, -currentB, tube_OD + (1+2*i)*wire_thickness, positionB-TurnsB(i)*wire_thickness-wire_thickness*(2*WeakTurnsB(i)-2), 1, -wire_thickness)
    
  %  AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, +currentB, tube_OD + (1+2*i)*wire_thickness, positionB-(TurnsB(i)+1)*wire_thickness, 1, -wire_thickness)
  %  AchievedFieldProfile=AchievedFieldProfile+ bfield1(z, -currentB, tube_OD + (1+2*i)*wire_thickness, positionB-(TurnsB(i)-2)*wire_thickness, 1, -wire_thickness)
    
   %Coil C Compensation Coil-wire_thickness*(2*WeakTurnsB(i)-1)

TurnsC=[7, 6, 0];
currentC=-115;

for i=1:length(TurnsC)
    AchievedFieldProfile= AchievedFieldProfile + bfield1(z, currentC, tube_OD + (1+2*i) * wire_thickness, positionB, TurnsC(i), wire_thickness);
end

%Output the Design B field and Achieved B field

figure(1);
subplot(2,1,1);
plot (z, AchievedFieldProfile, 'blue'); hold on;
plot (z, DesignFieldProfile, 'red'); 

legend('Achieved Field Profile','Design Field Profile','Location','SouthWest');

subplot(2,1,2);        

plot (z, AchievedFieldProfile-transpose(DesignFieldProfile), 'green');

legend('Deviation','Location','SouthWest');


%Coil Power and Voltage

%Lengths of wire in cm
%Resistances of each wire


%First section: Decreasing field coil

i=1:length(TurnsA);
CoilLengthsA =pi*(tube_OD + (-1+2*i)*wire_thickness).*TurnsA;
TotalLengthA = 200 + sum(CoilLengthsA);
ResistanceA = resistivity101*TotalLengthA/(wire_od^2-wire_id^2);
TotalVoltsA = ResistanceA*currentA;
TotalPowerA = currentA*TotalVoltsA;

fprintf('\r\tDecreasing field coil parameters \r\t\t')
fprintf('\r\t\ttotal coil length of the decreasing section: %1.2f cm \r\t\t',TotalLengthA)
%the coil length for each layer
%for i=1:length(TurnsA)
%    fprintf('%1.2f \r\t\t',CoilLengthsA(i))
%end
fprintf('\r\t\ttotal voltage and power requiered: %1.2f Volts and %1.2f Watts \r',TotalVoltsA,TotalPowerA)

%Second section: Increasing field coil, part 1
j=1:length(TurnsB);
N=length(TurnsB);
CoilLengthsB(1:(N-1)) =pi*(tube_OD + (-1+2*j(1:(N-1)))*wire_thickness).*TurnsB(1:(N-1));
CoilLengthsB(N) = 2*pi*(tube_OD + wire_thickness).*TurnsB(N);
TotalLengthB = 200 + sum(CoilLengthsB);
ResistanceB = resistivity101*TotalLengthB/(wire_od^2-wire_id^2);
TotalVoltsB = abs(ResistanceB*currentB);
TotalPowerB = abs(currentB*TotalVoltsB);

fprintf('\r\tIncreasing field coil parameters \r\t\t')
fprintf('\r\t\ttotal coil length of the increasing section (Single Spacing): %1.2f cm \r\t\t',TotalLengthB)
%the coil length for each layer
%for i=1:length(TurnsB)
%    fprintf('%1.2f \r\t\t',CoilLengthsB(i))
%end
fprintf('\r\t\ttotal voltage and power requiered: %1.2f Volts and %1.2f Watts \r',TotalVoltsB,TotalPowerB)

%Compensation Coil
k=1:length(TurnsC);
CoilLengthsC =pi*(tube_OD + (-1+2*k)*wire_thickness).*TurnsC;
TotalLengthC = 200 + sum(CoilLengthsC);
ResistanceC = resistivity101*TotalLengthC/(wire_od^2-wire_id^2);
TotalVoltsC = abs(ResistanceC*currentC);
TotalPowerC = abs(currentC*TotalVoltsC);

fprintf('\r\tCompensation field coil parameters \r\t\t')
fprintf('\r\t\ttotal coil length of the compensation coils : %1.2f cm \r\t\t',TotalLengthC)
%the coil length for each layer
%for i=1:length(TurnsC)
%    fprintf('%1.2f \r\t\t',CoilLengthsC(i))
%end
fprintf('\r\t\ttotal voltage and power requiered: %1.2f Volts and %1.2f Watts \r',TotalVoltsC,TotalPowerC)





