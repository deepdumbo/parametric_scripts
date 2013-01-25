%Version 1 in RAREvTR processing.
%Processes 1 image in one Direction
% oneDIRADC(A, B, 'linearsimp', 0, ones(5,5,10), 'single', 'extraCPU', 'multiCPU', '/data/scripts/ADC/processing')


function output = oneDIRADC(imagea, b_values, fitype, noise, mask, varargin)
  
  %ploter, noise, status, ...
   %                         jm, config, ADCpath, numCPUhold, mask)
  
    possibleinputs = {'mode'; 'jobm'; 'jobcfg'; 'ADCpath'; 'ploter';'numCPU'; 'bnought'};
    
%     bnought = 1;
%      indy = find_str_cell(varargin, 'bnought', 'n', 'n');
%      if(sum(indy(:))  == 1)
%        x = find(indy == 1);
%        bnought = varargin{x+1};
%      end
    
%      if(bnought)
%          actualbval = size(b_values,2) - 1;
%      else
         actualbval = size(b_values,2);
     %end
     
    width    = size(imagea,1);
    length   = size(imagea,2);
    slices   = size(imagea, 3)/ actualbval
    total    = width*length*slices;
    numBvals = size(b_values, 2);
    b_values;
    factor = -10;
    
   
    
    status  = 'single';
    jm      = 'extraCPU';
    config  = 'multiADC';
    ADCpath = '/data/scripts/ADC/processing';
    ploter      = 0;
    numCPUhold  = 1;
    niftpath = '/home/tommy/scripts/matlabcode/niftitools/';
   
     
     indy = find_str_cell(varargin, 'niftpath', 'n', 'n');
     if(sum(indy(:))  == 1)
       x = find(indy == 1);
       niftpath = varargin{x+1};
     end
    
    indy = find_str_cell(varargin, 'mode', 'n', 'n');
    if(sum(indy(:))  == 1)
      x = find(indy == 1);
      status = varargin{x+1};
    end
    
     indy = find_str_cell(varargin, 'jobm', 'n', 'n');
    if(sum(indy(:))  == 1)
      x = find(indy == 1);
      jm = varargin{x+1};
    end
    
     indy = find_str_cell(varargin, 'jobcfg', 'n', 'n');
    if(sum(indy(:))  == 1)
      x = find(indy == 1);
      config = varargin{x+1};
    end
    
     indy = find_str_cell(varargin, 'ADCpath', 'n', 'n');
    if(sum(indy(:))  == 1)
      x = find(indy == 1);
      ADCpath = varargin{x+1};
    end
    indy = find_str_cell(varargin, 'ploter', 'n', 'n');
    if(sum(indy(:))  == 1)
      x = find(indy == 1);
      ploter = varargin{x+1};
    end
    indy = find_str_cell(varargin, 'numCPU', 'n', 'n');
    if(sum(indy(:))  == 1)
      x = find(indy == 1);
      numCPUhold = varargin{x+1};
    end
    
    %Make the output stuff
    SzeroA = ones(width, length, slices).*factor;
    SADCA  = ones(width, length, slices).*factor;
    SRA    = ones(width, length, slices).*factor;
    SQA    = ones(width, length, slices).*factor;
    
  
    %Make Weighting Matrix
    W = ones(1,numBvals);
    sizera = size(noise);
    
    for i = 1:numBvals
      noisevolume = zeros(sizera(1), sizera(2), slices); 
      k = 1;
      for j = 1:slices
        (j-1)*numBvals+i;  
        noisevolume(:,:,k) = noise(:,:,(j-1)*numBvals+i);
        k = k+1;
      end
     
      noisevolume = noisevolume(:);
      onlynoisevolume = noisevolume;
      newnoisevolume = std(onlynoisevolume);
      
      if(newnoisevolume == 0)
        W(1,i) = 1;
      else
        W(1,i) = 1/(newnoisevolume)^2;
      end
    end
    clear noisevolume
    clear newonoisevolume
    clear onlynoisevolume
   
    W;
   
    %Fitype
    if(size(b_values, 2) == 2) 
      fitype = 'linearsimp';
    end
    
    %Calculate the output
  
  
    %Find the indices for the masked ROI     
    found = find(mask == 1);
    size(found);
    width*length*slices;
   
    
   
    
     fprintf(['Width:' num2str(width) ' Height:' num2str(length) ' Slices:' ...
             num2str(slices) ' Total Pixels:' num2str(total) '\nB-value:' ...
             num2str(b_values) ' \nNon-mask Factor:' num2str(factor) ['\nMasked ' ...
                         'Pixels:'] num2str(sum(mask(:))) ' Weighting Mat:' num2str(W) ' Fitype:' fitype ' NumCPU:' num2str(numCPUhold) '\n']);
    
    tic
      
      parfor (j = found')
          
         
          
        [SzeroA(j), SRA(j), SADCA(j), SQA(j)] = RAREVTRfit(b_values, j, W, slices, numBvals, ...
                                                          [size(mask,1), ...
                            size(mask,2)], imagea);
                        
                      
                            
      end
      
    toc
    

       
       
       
    disp('DONE with one direction')
    
    SADCA(100:110);
    SRA(1:10);
  
    output.Szero = reshape(SzeroA, [width, length, slices]);
    output.SADC  = reshape(SADCA,  [width, length, slices]);
    output.SR    = reshape(SRA, [width, length, slices]);
    output.SQ    = reshape(SQA, [width, length, slices]);
    
  
       
    