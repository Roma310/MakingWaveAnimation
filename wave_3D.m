clear all
% パラメータ
Lx = 1;   Ly = 1; % 領域の辺の長さ
Nx = 21; Ny = 21; % 分割数 (簡単のために，Nx = Nyとしておく)
gamma = 0.01; % 減衰係数
a = 30; % 初期形状のパラメタ
time = 20;  dt = 1e-4;
v = 4;

% 格子幅
dx = Lx/Nx; dy = Ly/Ny;
% 初期条件
x = 0:dx:Lx-dx;
y = 0:dy:Ly-dy;
[X, Y] = meshgrid(x, y); % メッシュ
Z_init = 1*exp(-a*((X - Lx/4).^2 + (Y - Ly/4).^2)); ...
    %+ 10*exp(-a*((X - 3*Lx/4).^2 + (Y - 3*Ly/4).^2)); % 初期形状
V_init = X*0; % 初期速度
% ふちを0にする
Z_init(1,:) = zeros(1,Nx);
Z_init(:,1) = zeros(Nx,1);
Z_init(Nx,:) = zeros(1,Nx);
Z_init(:,Nx) = zeros(Nx,1);
Z_init(5:10,15:18) = 0;
% 計算
[Z, ~] = wave_3dim(Z_init, V_init, Lx, Ly, Nx, time, dt, v, gamma);
% プロット
for t = 1:15
    subplot(5,3,t);
    surf(X, Y, Z(:, :, int64((t-1)/dt) + 1));
    title(["Time", t, "s"]);
end

%% アニメーション作成
% step 1
% もう計算済み
% step 2
fig = figure; % figureオブジェクト
% txt = text(0, 0, '', 'FontSize', 32, 'HorizontalAlignment', 'center');
plt = surf(X, Y, Z(:, :, 1));
% 動画の長さは100フレーム
zlim([-1 1])
num = int64(time/dt);
% フレームレート 
Frate = 20;

v = VideoWriter('Wave-b_alt','MPEG-4');
v.FrameRate = Frate; % Framerate
open(v); % ファイルを開く
for k = 1:10:num/50
    % 図の更新
    plt.ZData = Z(:, :, k + 1);
    % 描画実行
    drawnow;
    frame = getframe(fig);
    writeVideo(v,frame);
end
close(v); % ファイルを閉じる

% step 3
% switch exporttype % 今回は出力方法を exporttype 変数で指定することにする
%     case 'mp4' % 普通の動画の場合
%         video = VideoWriter('filename.mp4', 'MPEG-4'); % ファイル名や出力形式などを設定
%         open(video); % 書き込むファイルを開く
%         writeVideo(video, frames); % ファイルに書き込む
%         close(video); % 書き込むファイルを閉じる
%     case 'gif'
%         filename = 'filename.gif'; % ファイル名
%         for i = 1:100
%             [A, map] = rgb2ind(frame2im(frames(i)), 256); % 画像形式変換
%             if i == 1
%                 imwrite(A, map, filename, 'gif', 'DelayTime', 1/30); % 出力形式(30FPS)を設定
%             else
%                 imwrite(A, map, filename, 'gif', 'DelayTime', 1/30, 'WriteMode', 'append'); % 2フレーム目以降は"追記"の設定も必要
%             end
%         end
% end