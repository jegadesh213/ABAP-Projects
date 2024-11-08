*&---------------------------------------------------------------------*
*& Report Z_ALVPRO_03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_alvpro_03.

TABLES: zstoov.

TYPE-POOLS : slis.

TYPES : ty_stock TYPE zstoov.

DATA : it_stock  TYPE TABLE OF ty_stock,
       wa_stock  TYPE ty_stock,
       it_fldcat TYPE slis_t_fieldcat_alv,
       wa_fldcat TYPE slis_fieldcat_alv,
       it_sort   TYPE slis_t_sortinfo_alv,
       wa_sort   TYPE slis_sortinfo_alv,
       wa_layout TYPE slis_layout_alv,
       it_event  TYPE slis_t_event,
       wa_event  TYPE slis_alv_event.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS: p_id FOR zstoov-matid.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM fetch_data.
  PERFORM fldcat_data.
  PERFORM sort_data.
  PERFORM show_data.

*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data.
  SELECT * FROM zstoov INTO CORRESPONDING FIELDS OF TABLE it_stock WHERE matid IN p_id.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form fldcat_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fldcat_data .

  wa_fldcat-fieldname = 'MATID'.
  wa_fldcat-tabname = 'it_stock'.
  wa_fldcat-seltext_m = 'Material ID'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'MATERIALDESC'.
  wa_fldcat-tabname = 'it_stock'.
  wa_fldcat-seltext_m = 'Material Descrption'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'STORLOC'.
  wa_fldcat-tabname = 'it_stock'.
  wa_fldcat-seltext_m = 'Storage Location'.
  wa_fldcat-outputlen = 10.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'PLANT'.
  wa_fldcat-tabname = 'it_stock'.
  wa_fldcat-seltext_m = 'Plant'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'STOCKQ'.
  wa_fldcat-tabname = 'it_stock'.
  wa_fldcat-seltext_m = 'Stock Quantity'.
  wa_fldcat-do_sum = 'X'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'BATCHNUM'.
  wa_fldcat-tabname = 'it_stock'.
  wa_fldcat-seltext_m = 'Batch Number'.
  APPEND wa_fldcat TO it_fldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form show_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_data .

  wa_layout-colwidth_optimize = 'X'.
  wa_layout-zebra = 'X'.
  wa_layout-no_sumchoice = 'X'.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      = ' '
*     I_BUFFER_ACTIVE         = ' '
      i_callback_program      = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
      i_callback_user_command = 'USER_COMMAND'
      i_callback_top_of_page  = 'F_TOP_OF_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME        =
*     I_BACKGROUND_ID         = ' '
*     I_GRID_TITLE            =
*     I_GRID_SETTINGS         =
      is_layout               = wa_layout
      it_fieldcat             = it_fldcat
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
      it_sort                 = it_sort
*     IT_FILTER               =
*     IS_SEL_HIDE             =
*     I_DEFAULT               = 'X'
*     I_SAVE                  = ' '
*     IS_VARIANT              =
*     IT_EVENTS               =
*     IT_EVENT_EXIT           =
*     IS_PRINT                =
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
*     I_HTML_HEIGHT_TOP       = 0
*     I_HTML_HEIGHT_END       = 0
*     IT_ALV_GRAPHICS         =
*     IT_HYPERLINK            =
*     IT_ADD_FIELDCAT         =
*     IT_EXCEPT_QINFO         =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab                = it_stock
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

FORM f_top_of_page.

  DATA : it_lheader TYPE slis_t_listheader,
         wa_lheader TYPE slis_listheader.


  wa_lheader-typ  = 'H'.
  wa_lheader-info = 'Stock Overview Report'.
  APPEND wa_lheader TO it_lheader.

  wa_lheader-typ  = 'A'.
  wa_lheader-info = sy-datum.
  APPEND wa_lheader TO it_lheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_lheader.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form sort_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sort_data .

  wa_sort-spos = 1.
  wa_sort-fieldname = 'MATID'.
  wa_sort-up = 'X'.
  wa_sort-subtot = 'X'.
  APPEND wa_sort TO it_sort.

  wa_sort-spos = 2.
  wa_sort-fieldname = 'PLANT'.
  wa_sort-up = 'X'.
  wa_sort-subtot = 'X'.
  APPEND wa_sort TO it_sort.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm TYPE sy-ucomm
                          r_row TYPE i.
  DATA: lv_storloc TYPE zstoov-storloc.

  CASE r_ucomm.
    WHEN 'DETAIL'.
      " Fetch the storage location from the selected row (r_row)
      lv_storloc = it_stock[ r_row ]-storloc.  " Correct reference to get the selected row data

      " Call the function to show batch details for the selected storage location
      PERFORM show_batch_details USING lv_storloc.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form show_batch_details
*&---------------------------------------------------------------------*
FORM show_batch_details USING iv_storloc TYPE zstoov-storloc.
  DATA: it_batches TYPE TABLE OF zstoov,
        wa_batch   TYPE zstoov.

  " Fetch the batch details based on the storage location
  SELECT * FROM zstoov
    INTO TABLE it_batches
    WHERE storloc = iv_storloc.

  " Display the batch details in a new ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = wa_layout
      it_fieldcat        = it_fldcat
    TABLES
      t_outtab           = it_batches
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
