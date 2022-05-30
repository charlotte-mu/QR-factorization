clc;
clear all;

%% 

data_in = [
    4 3 1 2 ;
    3 4 1 2 ;
    3 4 2 1 ;
    3 2 4 1 ;
    2 3 4 1 ;
    2 3 1 4 ;
    2 1 3 4 ;
    1 2 3 4 ;
];

data_in = data_in * 2^8;

[ data_out(:,1), di_out(:,:,1)] = testGG( data_in(:,1), 7);
[ data_temp(1:7,1,1),data_out(8,2)] = testGR( data_in(:,2), di_out(:,:,1), 7);
[ data_temp(1:7,2,1),data_out(8,3)] = testGR( data_in(:,3), di_out(:,:,1), 7);
[ data_temp(1:7,3,1),data_out(8,4)] = testGR( data_in(:,4), di_out(:,:,1), 7);

[ data_out(1:7,2), di_out(1:6,:,2)] = testGG( data_temp(:,1,1), 6);
[ data_temp(1:6,1,2),data_out(7,3)] = testGR( data_temp(:,2,1), di_out(:,:,2), 6);
[ data_temp(1:6,2,2),data_out(7,4)] = testGR( data_temp(:,3,1), di_out(:,:,2), 6);

[ data_out(1:6,3), di_out(1:5,:,2)] = testGG( data_temp(:,1,2), 5);
[ data_temp(1:5,1,3),data_out(6,4)] = testGR( data_temp(:,2,2), di_out(:,:,2), 5);

[ data_out(1:5,4), di_out(1:4,:,3)] = testGG( data_temp(:,1,3), 4);

 
 
 %%
data_out = flipud(data_out);