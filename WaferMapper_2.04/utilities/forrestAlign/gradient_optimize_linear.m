function [values,error,Esave]=gradient_optimize_linear(relerror,iters,delt,goodmatrix)
%this function takes a set of relative transformation parameters that add
%linearly (for instance angle, and x,y offset) across many different
%comparisons between different sections of a stack, and attempts to find a
%set of parameters (one for each sections) that globally fits all these
%relative parameters using gradient descent,
%using a mean subtracted normalization step at each timepoint.
%
%inputs
%relerror is a ZxZ matrix containing the relative parameters when
%transforming the section in row i onto the section in row j.
%iters is the number of iterations of gradient descent to attempt
%delt is the size of the gradient descent steps
%goodmatrix is a matrix which contains a 1 where there is a proper relative
%parameter measurement and a 0 otherwise.
%
%outputs
%values: is a 1xZ vector containing the final converged upon
%set of parameters (one for each slice)
%
%error: this is a ZxZ matrix which describes how far away from the desired
%relative parameter does the single global set of parameters get.
%for instance if section 1 ends up with an angle of 0 and section 10 has an
%angle of 15, but the relative angle between 1 and 10 was suppose to be 17
%then error would be -2 for error(1,10).
%
%Esave: is the set of energy values for the gradient descent across the
%iterations.
   Z=size(goodmatrix,1);
   values=zeros(1,Z);
   Esave=zeros(1,iters);
   goodones=find(goodmatrix>0);
   badones=find(goodmatrix==0);
   for i=1:iters

       repvalue_i=repmat(values,Z,1);
       repvalue_j=repmat(values',1,Z);
       error=(repvalue_j-repvalue_i-relerror);
       error(badones)=0;
       Esave(i)=sum(error(goodones).^2);
       
       de=zeros(1,Z);
       for k=1:Z
          relvalues_ik=relerror(:,k);

          de1=(values-values(k)-relvalues_ik');
          
          de1cut=de1(goodmatrix(:,k)==1);
          compared_sections=find(goodmatrix(:,k)==1);

          if isempty(compared_sections)
              de(k)=sum(de1cut);
          else
              de(k)=sum(de1cut);
              % de(k)=sum(de1cut*sqrt(abs(compared_sections-k)));
          end
       end      
        values=values+delt*de;
        values=values-mean(values);

   end
       figure(31);
       clf;
       plot(1:i,Esave(1:i));
        
       figure(41);
       clf;
       imagesc(error);
       colorbar;

        figure(61);
        clf;
        bar(values);
        pause(.1);