
function [Xp, im]=registration(X, main, optim)

[eta, ddx, ddy,ddz,Force ,im]=similarity(main);

optim.tau=optim.tau/std([ddx(:); ddy(:) ;ddz(:)],0);

[Xp, regValue]=regsolve(X,Force,main, optim, 1);     % compute the regularization term and update the transformation
f =eta+regValue ;                                % compute the value of the total objective function (similarity + regularization)

fchange=optim.stopping_criterion+1;
iter=0;

while (abs(fchange)>optim.stopping_criterion  && (iter<optim.maxsteps))
    
    
    [Xp, regValue]=regsolve(X,Force,main, optim);   
  
    % compute new function value and new gradient
    
    [eta,Force,imb]=similarity2(main, Xp);

    fp= eta+regValue  ;   % ���� ���
    
    fchange=(f-fp)/f;
            
    %check if the step size is appropriate
    if ((fp-f)>0),
         % ���� ��� j ���� min ��� ǐ� �����  �� fp ���� �� ���� ��� ��  f
         %  ����� ��� ���� ����� ����� ���� �� �� �� ���� �� �����
         %  regvalue �� ���� ��� 
          % � �� ����� ����� ���� ��� �� ������ ������ .
        %if the new objective function value does not decrease,
        %then reduce the optimization step size and
        %slightly increase the value of the objective function
        %(this is an optimization heuristic to avoid some local minima)
        optim.tau=optim.tau*optim.anneal;
        f=f+ 0.1*abs(f);
        
    else
        X=Xp; f=fp;  im = imb;
       
%         mesh_epsplot(X(:,:,round(end/2),1),X(:,:,round(end/2),2)); drawnow;
       
        % show progress
        disp([upper(main.similarity) ' ' num2str(eta)          ' Error ' num2str(fchange)          ' iter ' num2str(iter)          ' level'   num2str(main.level)          ' tau = ' num2str(optim.tau)]);
    end;
    iter=iter+1;
end
