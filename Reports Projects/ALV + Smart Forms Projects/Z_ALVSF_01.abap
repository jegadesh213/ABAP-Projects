*&---------------------------------------------------------------------*
*& Report Z_ALVSF_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_alvsf_01.

TABLES : zzempprac , zzempracdep.

TYPE-POOLS : slis.

TYPES : BEGIN OF ty_employee,
          emplnum   TYPE zzempprac-emplnum,
          emplname  TYPE zzempprac-emplname,
          empdept   TYPE zzempprac-empdept,
          empsalary TYPE zzempprac-empsalary,
          units     TYPE zzempprac-units,

          role      TYPE zzempracdep-role,
          doj       TYPE zzempracdep-doj,
        END OF ty_employee.

DATA : it_employee TYPE TABLE OF ty_employee,
       wa_employee TYPE ty_employee.

DATA : it_fldcat TYPE slis_t_fieldcat_alv,
       wa_fldcat TYPE slis_fieldcat_alv.

DATA : fm_name            TYPE  rs38l_fnam,
       control_parameters TYPE  ssfctrlop,
       output_options     TYPE  ssfcompop.

DATA : p_num  TYPE char3,
       p_name TYPE char30,
       p_dep  TYPE char10,
       p_sal  TYPE char21,
       p_unit TYPE char5,
       p_doj  TYPE char10,
       p_role TYPE char10.

DATA  : wa_layout TYPE slis_layout_alv.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_num FOR zzempprac-emplnum.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM fetch_data.
  PERFORM make_fldcat.
  PERFORM show_data.

*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data .
  SELECT a~emplnum a~emplname a~empdept a~empsalary a~units b~role b~doj FROM zzempprac AS a INNER JOIN zzempracdep AS b ON
    a~emplnum = b~emplnum INTO CORRESPONDING FIELDS OF TABLE it_employee WHERE a~emplnum IN s_num.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_fldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_fldcat .

  wa_fldcat-fieldname = 'EMPLNUM'.
  wa_fldcat-tabname = 'it_employee'.
  wa_fldcat-seltext_m = 'Employee Number'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'EMPLNAME'.
  wa_fldcat-tabname = 'it_employee'.
  wa_fldcat-seltext_m = 'Employee Name'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'EMPDEPT'.
  wa_fldcat-tabname = 'it_employee'.
  wa_fldcat-seltext_m = 'Department'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'EMPSALARY'.
  wa_fldcat-tabname = 'it_employee'.
  wa_fldcat-seltext_m = 'Salary'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'UNITS'.
  wa_fldcat-tabname = 'it_employee'.
  wa_fldcat-seltext_m = 'Units'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'ROLE'.
  wa_fldcat-tabname = 'it_employee'.
  wa_fldcat-seltext_m = 'Role'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'DOJ'.
  wa_fldcat-tabname = 'it_employee'.
  wa_fldcat-seltext_m = 'Date of Joining'.
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

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
*     I_BYPASSING_BUFFER       = ' '
*     I_BUFFER_ACTIVE          = ' '
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'F_TOP_OF_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME         =
*     I_BACKGROUND_ID          = ' '
*     I_GRID_TITLE             =
*     I_GRID_SETTINGS          =
      is_layout                = wa_layout
      it_fieldcat              = it_fldcat
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
*     IT_SORT                  =
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     I_DEFAULT                = 'X'
*     I_SAVE                   = ' '
*     IS_VARIANT               =
*     IT_EVENTS                =
*     IT_EVENT_EXIT            =
*     IS_PRINT                 =
*     IS_REPREP_ID             =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
*     I_HTML_HEIGHT_TOP        = 0
*     I_HTML_HEIGHT_END        = 0
*     IT_ALV_GRAPHICS          =
*     IT_HYPERLINK             =
*     IT_ADD_FIELDCAT          =
*     IT_EXCEPT_QINFO          =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER  =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = it_employee
*   EXCEPTIONS
*     PROGRAM_ERROR            = 1
*     OTHERS                   = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

FORM f_top_of_page.

  DATA : it_header TYPE slis_t_listheader,
         wa_header TYPE slis_listheader.

  wa_header-typ = 'H'.
  wa_header-info = 'Employee Detail Table'.
  APPEND wa_header TO it_header.

  wa_header-typ = 'A'.
  wa_header-info = sy-datum.
  APPEND wa_header TO it_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_header
*     I_LOGO             =
*     I_END_OF_LIST_GRID =
*     I_ALV_FORM         =
    .

ENDFORM.

FORM set_pf_status USING rt_extab TYPE slis_t_extab..

  SET PF-STATUS 'ZALVSF'.

ENDFORM.

FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_slisfld TYPE slis_selfield.

  CASE r_ucomm.

    WHEN 'ADD'.
      CALL SCREEN 0200.
    WHEN 'DEL'.
      READ TABLE it_employee INTO wa_employee INDEX rs_slisfld-tabindex.
      IF sy-subrc = 0.
        DELETE it_employee INDEX rs_slisfld-tabindex.
        DELETE FROM zzempprac WHERE emplnum = wa_employee-emplnum.
        DELETE FROM zzempracdep WHERE emplnum = wa_employee-emplnum.
      ENDIF.
      rs_slisfld-refresh = 'X'.
    WHEN 'REFRESH'.
      rs_slisfld-refresh = 'X'.
      PERFORM fetch_data.
      PERFORM show_data.
    WHEN 'SAVE'.
      MESSAGE 'Saved Successfully' TYPE 'I'.
    WHEN '&IC1'.
      READ TABLE it_employee INTO wa_employee INDEX rs_slisfld-tabindex.
      IF wa_employee-emplnum IS NOT INITIAL.
        PERFORM call_sf.
      ENDIF.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'PF-02'.
  SET TITLEBAR 'T-01'.
ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 0.
    WHEN 'SAVE'.
      DATA : wa_employee02 TYPE ty_employee.

      wa_employee02-emplnum = p_num .
      wa_employee02-emplname = p_name .
      wa_employee02-empdept =  p_dep.
      wa_employee02-empsalary = p_sal.
      wa_employee02-units = p_unit .
      wa_employee02-role = p_role.
      wa_employee02-doj = p_doj.

      INSERT INTO zzempprac VALUES wa_employee02.
      INSERT INTO zzempracdep VALUES wa_employee02.

      IF sy-subrc = 0.
        MESSAGE 'Record added successfully' TYPE 'S'.
      ELSE.
        MESSAGE 'Failed to add record' TYPE 'E'.
      ENDIF.
  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Form call_sf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_sf .

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'Z_ALVSF_01'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      fm_name            = fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  control_parameters-preview    = 'X'.
  control_parameters-no_dialog  = 'X'.

  output_options-tddest = 'LP01'.

  CALL FUNCTION '/1BCDWB/SF00000099'
    EXPORTING
*     ARCHIVE_INDEX      =
*     ARCHIVE_INDEX_TAB  =
*     ARCHIVE_PARAMETERS =
      control_parameters = control_parameters
*     MAIL_APPL_OBJ      =
*     MAIL_RECIPIENT     =
*     MAIL_SENDER        =
      output_options     = output_options
      user_settings      = 'X'
      p_num              = wa_employee-emplnum
* IMPORTING
*     DOCUMENT_OUTPUT_INFO       =
*     JOB_OUTPUT_INFO    =
*     JOB_OUTPUT_OPTIONS =
* EXCEPTIONS
*     FORMATTING_ERROR   = 1
*     INTERNAL_ERROR     = 2
*     SEND_ERROR         = 3
*     USER_CANCELED      = 4
*     OTHERS             = 5
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.



ENDFORM.