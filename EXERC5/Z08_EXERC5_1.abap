*&---------------------------------------------------------------------*
*& Report Z08_EXERC5_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc5_1.

DATA: v_l_usuario_rede TYPE z08usuario_rede,
      t_usuario_rede  TYPE z08usuario_rede.

v_l_usuario_rede-mandt        = '400'.
v_l_usuario_rede-codigo       = '102'.
v_l_usuario_rede-nome         = 'João'.
v_l_usuario_rede-sobrenome    = 'Vitor'.
v_l_usuario_rede-data_inicial = '20240101'.
v_l_usuario_rede-data_final   = '20250202'.
v_l_usuario_rede-username     = 'jvtor'.
v_l_usuario_rede-data_criacao = '20230303'.
v_l_usuario_rede-user_resp    = '12345'.
v_l_usuario_rede-ativo        = 'X'.


INSERT INTO z08usuario_rede VALUES v_l_usuario_rede.