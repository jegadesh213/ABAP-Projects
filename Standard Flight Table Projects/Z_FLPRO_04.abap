*&---------------------------------------------------------------------*
*& Report Z_FLPRO_04
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_flpro_04.

TABLES : stravelag,scustom.

TYPES : BEGIN OF ty_cust,
          agencynum TYPE stravelag-agencynum,
          tname     TYPE stravelag-name,
          tcity     TYPE stravelag-city,

          id        TYPE scustom-id,
          cname     TYPE scustom-name,
          form      TYPE scustom-form,
          ccity     TYPE scustom-city,
        END OF ty_cust.

DATA : it_cust TYPE TABLE OF ty_cust,
       wa_cust TYPE ty_cust.

DATA : it_fldcat  TYPE lvc_t_fcat,
       wa_fldcat  TYPE lvc_s_fcat,
       it_toolbar TYPE TABLE OF stb_button,
       wa_toolbar TYPE  stb_button.

DATA : container TYPE REF TO cl_gui_custom_container,
       grid      TYPE REF TO cl_gui_alv_grid.

CLASS handle_events DEFINITION.

  PUBLIC SECTION.
    METHODS : handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_object e_interactive,
      handler_usercommand FOR EVENT user_command OF cl_gui_alv_grid IMPORTING e_ucomm.

ENDCLASS.

CLASS handle_events IMPLEMENTATION.

  METHOD handle_toolbar.

    wa_toolbar-butn_type = 0.
    wa_toolbar-function = 'INSERT'.
    wa_toolbar-icon = '@17@'.
    wa_toolbar-quickinfo = 'Insert'.
    APPEND wa_toolbar TO it_toolbar.

    CLEAR wa_toolbar.
    wa_toolbar-function  = 'DELETE'.
    wa_toolbar-butn_type = 0.
    wa_toolbar-icon      = '@18@'.
    wa_toolbar-quickinfo = 'Delete'.
    APPEND wa_toolbar TO it_toolbar.

    CLEAR wa_toolbar.
    wa_toolbar-function  = 'REFRESH'.
    wa_toolbar-butn_type = 0.
    wa_toolbar-icon      = '@42@'.
    wa_toolbar-quickinfo = 'Refresh'.
    APPEND wa_toolbar TO it_toolbar.


    APPEND LINES OF it_toolbar TO e_object->mt_toolbar.




  ENDMETHOD.


  METHOD handler_usercommand.


    CASE e_ucomm.
      WHEN 'INSERT'.
        PERFORM insert_data.
      WHEN 'DELETE'.
        PERFORM delete_data.
      WHEN 'REFRESH'.
        PERFORM fetch_data.
        CALL METHOD grid->refresh_table_display.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.

DATA : event_handler TYPE REF TO handle_events.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : p_cl TYPE stravelag-mandt.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  p_cl = '510'.

START-OF-SELECTION.
  PERFORM fetch_data.
  CALL SCREEN 0100.

*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data .

  SELECT a~agencynum a~name a~city b~id b~name b~form b~city FROM stravelag AS a INNER JOIN scustom AS b ON a~mandt = b~mandt
    INTO TABLE it_cust WHERE a~mandt = p_cl.

ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF-01'.
  SET TITLEBAR 'xxx'.

  CREATE OBJECT container
    EXPORTING
      container_name = 'ZCONTAINER'.

  CREATE OBJECT grid
    EXPORTING
      i_parent = container.

  CREATE OBJECT event_handler.
  SET HANDLER event_handler->handle_toolbar FOR grid.
  SET HANDLER event_handler->handler_usercommand FOR grid.

  PERFORM fld_cat.
  PERFORM display_data.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT' .
      SET SCREEN 0.
    WHEN 'SAVE'.
      " Ensure ALV data is updated
      CALL METHOD grid->check_changed_data.

      DATA: wa_stravelag TYPE stravelag,
            wa_scustom   TYPE scustom.


      " Update database table STRAVELAG
      LOOP AT it_cust INTO wa_cust.
        CLEAR: wa_stravelag .
        wa_stravelag-agencynum = wa_cust-agencynum.
        wa_stravelag-name = wa_cust-tname.
        wa_stravelag-city = wa_cust-tcity.

        MODIFY stravelag FROM wa_stravelag.
      ENDLOOP.

      " Update database table SCUSTOM
      LOOP AT it_cust INTO wa_cust.
        CLEAR: wa_scustom.
        wa_scustom-id = wa_cust-id.
        wa_scustom-name = wa_cust-cname.
        wa_scustom-form = wa_cust-form.
        wa_scustom-city = wa_cust-ccity.

        MODIFY scustom FROM wa_scustom.
      ENDLOOP.

      COMMIT WORK.

      MESSAGE 'Data saved successfully' TYPE 'S'.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Form fld_cat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fld_cat .
  wa_fldcat-fieldname = 'AGENCYNUM'.
  wa_fldcat-seltext = 'AGENCY NUMBER'.
  wa_fldcat-reptext = 'NUMBER'.
*  wa_fldcat-edit = 'X'.
  wa_fldcat-outputlen = 12.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'TNAME'.
  wa_fldcat-seltext = 'AGENCY NAME'.
  wa_fldcat-reptext = 'NAME'.
*  wa_fldcat-edit = 'X'.
  wa_fldcat-outputlen = 18.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'TCITY'.
  wa_fldcat-seltext = 'AGENCY CITY'.
  wa_fldcat-reptext = 'CITY'.
*  wa_fldcat-edit = 'X'.
  wa_fldcat-outputlen = 16.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'ID'.
  wa_fldcat-seltext = 'CUSTOMER ID'.
  wa_fldcat-reptext = 'CUSTOMER ID'.
*  wa_fldcat-edit = 'X'.
  wa_fldcat-outputlen = 12.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'CNAME'.
  wa_fldcat-seltext = 'CUSTOMER NAME'.
  wa_fldcat-reptext = 'NAME'.
*  wa_fldcat-edit = 'X'.
  wa_fldcat-outputlen = 12.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'FORM'.
  wa_fldcat-seltext = 'CUSTOMER FROM'.
  wa_fldcat-reptext = 'FROM'.
*  wa_fldcat-edit = 'X'.
  wa_fldcat-outputlen = 12.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'CCITY'.
  wa_fldcat-seltext = 'CUSTOMER CITY'.
  wa_fldcat-reptext = 'CITY'.
*  wa_fldcat-edit = 'X'.
  wa_fldcat-outputlen = 12.
  APPEND wa_fldcat TO it_fldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

  CALL METHOD grid->set_table_for_first_display
*    EXPORTING
*      i_buffer_active               =
*      i_bypassing_buffer            =
*      i_consistency_check           =
*      i_structure_name              =
*      is_variant                    =
*      i_save                        =
*      i_default                     = 'X'
*      is_layout                     =
*      is_print                      =
*      it_special_groups             =
*      it_toolbar_excluding          =
*      it_hyperlink                  =
*      it_alv_graphics               =
*      it_except_qinfo               =
*      ir_salv_adapter               =
    CHANGING
      it_outtab       = it_cust
      it_fieldcatalog = it_fldcat
*     it_sort         =
*     it_filter       =
*    EXCEPTIONS
*     invalid_parameter_combination = 1
*     program_error   = 2
*     too_many_lines  = 3
*     others          = 4
    .
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*& Form insert_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM insert_data .

  DATA: lv_index TYPE i.

  " Get selected row index
  CALL METHOD grid->get_selected_rows
    IMPORTING
      et_index_rows = DATA(lt_selected_rows).

  " Default to first row if no selection
  READ TABLE lt_selected_rows INTO DATA(ls_selected_row) INDEX 1.
  IF sy-subrc = 0.
    lv_index = ls_selected_row-index.
  ELSE.
    lv_index = lines( it_cust ) + 1. " Append at the end if no row is selected
  ENDIF.

  " Insert a blank row at the selected position
  CLEAR wa_cust.
  INSERT wa_cust INTO it_cust INDEX lv_index + 1.

  " Refresh ALV
  CALL METHOD grid->refresh_table_display.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form delete_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_data .

ENDFORM.