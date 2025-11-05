%%
fpath2 = ('C:\Users\belab\OneDrive - Florida Institute of Technology\Documents\Florida Tech\0_NeuroLab\LiveAmp_pilot_study\live-amp-pilot\data\sub-P005\P005-data-P3P4-dry\');

times = linspace(-100, 996, 275);
numbers = [1 3 5];
titles = {'Fz' 'F4' 'Cz' 'P4' 'Pz' 'P3' 'F3'};
pdfFile = 'Jack.pdf';

tmp = load([fpath2 'P005-S001_final.mat']);

tmp = tmp.tmp; 

figure
tmpo = tmp;
for i = 1:3
    subplot(3,1,i)
    plot(times,tmpo(numbers(i),:,1),'b','LineWidth',1.5);title(string(titles(1,numbers(1,i))));xlabel('time(ms)');ylabel('Amplitude (\muV)');
    hold on;
    plot(times,tmpo(numbers(i),:,2),'r','LineWidth',1.5);
    legend('Standard', 'Deviant');
    xlim([-100 996])
    set(gca,'Fontsize',10);
    grid on;
end
sgtitle('Participant ERPs')
exportgraphics(gcf, pdfFile, 'Append', true);
