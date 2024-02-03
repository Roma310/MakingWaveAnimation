function [z, z_t] = wave_3dim(init_z, init_v, Lx, Ly, N, time, dt, velocity, gamma)
% 2次元の波動方程式
% z_tt = v^2 (z_xx + z_yy) - gamma * z_t
% 以下コード
    % 正方形領域かつ縦・横同じ数だけ分割する
    % 空の行列
    num = int64(time*(dt)^(-1));
    z = zeros(N, N, num);
    z_t = zeros(N, N, num);
    % 初期値
    z(:,:,1) = init_z;
    z_t(:,:,1) = init_v;
    % 状態ベクトル Y := [z_11, ..., z_1n, ..., z_nn, v_11, ..., v_nn]
    % 状態方程式
    e = ones(N, 1); % 縦ベクトル
    W = (velocity*N/Lx)^2 * full(spdiags([e, -2*e, e], -1:1, N, N)); % 部分行列
    A = [zeros(N), eye(N); W, -gamma*eye(N)]; % 係数行列A
    W_alt = (velocity*N/Ly)^2 * full(spdiags([e, -2*e, e], -1:1, N, N)); % 部分行列
%     B = [zeros(N); W_alt]; % 係数行列B
    % 固定端条件
    reset = zeros(1, N); % リセットのための横ベクトル
    % Aの補正
    A(N+1, :) = [reset, reset];
    A(2*N, :) = [reset, reset];
    % Bの補正
%     B(N+1, :) = reset;
%     B(2*N, :) = reset;
    
    
    % 改良オイラー法
    % 初期値
    z_m = [z(:,:,1); z_t(:,:,1)];
    z_2nd = [zeros(N, N); z(:,:,1)];
    for n = 2:time/dt
        % step 1
        Z = z_m + (A*z_m + z_2nd*W_alt)*dt;
        % 固定端初期化
        Z(1,:) = reset;
        Z(N,:) = reset;
        Z(N+1,:) = reset;
        Z(2*N,:) = reset;
        Z(:,1) = zeros(2*N, 1);
        Z(:,N) = zeros(2*N, 1);
        % 障害物
        %Z(5:10,15:18) = 0;
        % step 2
        Z_2nd = [zeros(N, N); Z(1:N,:)];
        z_m = z_m + (A*z_m + z_2nd*W_alt)*dt/2 + (A*Z + Z_2nd*W_alt)*dt/2;
        % 固定端初期化
        z_m(1,:) = reset;
        z_m(N,:) = reset;
        z_m(N+1,:) = reset;
        z_m(2*N,:) = reset;
        z_m(:,1) = zeros(2*N, 1);
        z_m(:,N) = zeros(2*N, 1);
        % 障害物
        %z_m(5:10,15:18) = 0;
        % 出力
        z(:, :, n) = z_m(1:N, :);
        z_t(:, :, n) = z_m(N+1:2*N, :);
        % 次のループのための準備
        z_2nd = [zeros(N, N); z(:,:,n)];
    end
end

