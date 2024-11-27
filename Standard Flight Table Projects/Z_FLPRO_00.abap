*&---------------------------------------------------------------------*
*& Report Z_FLPRO_00
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_flpro_00.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN SKIP.

  PARAMETERS : p_01 RADIOBUTTON GROUP g_01,
               p_02 RADIOBUTTON GROUP g_01.

  SELECTION-SCREEN SKIP.

  PARAMETERS : a AS CHECKBOX DEFAULT 'X',
               b AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

  IF a IS NOT INITIAL.
    IF p_01 IS NOT INITIAL.
      SUBMIT z_flpro_01 VIA SELECTION-SCREEN AND RETURN.
    ELSEIF p_02 IS NOT INITIAL.
      SUBMIT z_flpro_02 VIA SELECTION-SCREEN AND RETURN.
    ENDIF.
  ELSEIF b IS NOT INITIAL.
    IF p_01 IS NOT INITIAL.
      SUBMIT z_flpro_03 VIA SELECTION-SCREEN AND RETURN.
    ENDIF.
  ENDIF.
