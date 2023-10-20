function sweepGatesUpdate(voltages,outputs,inputs) %output and input channel, e.g. AO1, AI1

if length(voltages)~=length(outputs)
    error('number of voltages must equal number of outputs')
end

if length(inputs)~=length(outputs)
    error('number of inputs must equal number of outputs')
end

dV = 0.002;
StepsPerSec =200;
daqObject = daq.createSession('ni');
device='Dev1';

for i=1:length(outputs)
daqObject.addAnalogOutputChannel(device,['ao' num2str(outputs(i))], 'Voltage');
end

for i=1:length(inputs)
daqObject.addAnalogInputChannel(device,['_ao' num2str(inputs(i)) '_vs_aognd'], 'Voltage');
end

startV=daqObject.inputSingleScan

if size(startV)~=size(voltages)
    error('Dim mismatch on starting voltages')
end

Nsteps=ceil(max(abs((voltages-startV)/dV)));

Vsteps=NaN(Nsteps,length(voltages));
for i=1:length(voltages)
    Vsteps(:,i)=linspace(startV(i),voltages(i),Nsteps);
end

for i=1:Nsteps
    pause(1/StepsPerSec)
    daqObject.outputSingleScan(Vsteps(i,:));
    if mod(i,StepsPerSec)==0
        disp([num2str(Vsteps(i,:)) '...'])
    end
end
daqObject.release;