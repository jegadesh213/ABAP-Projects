*&---------------------------------------------------------------------*
*& Report Z_FLPRO_03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_flpro_03.

TABLES : scarr,scounter,spfli,sflight.

TYPES : BEGIN OF ty_ft,
          carrid     TYPE scarr-carrid,

          airport    TYPE scounter-airport,

          cityfrom   TYPE spfli-cityfrom,
          cityto     TYPE spfli-cityto,

          fldate     TYPE sflight-fldate,
          price      TYPE sflight-price,
          currency   TYPE sflight-currency,
          paymentsum TYPE sflight-paymentsum,
        END OF ty_ft.

DATA : it_ft TYPE TABLE OF ty_ft,
       wa_ft TYPE ty_ft.

DATA :lv_filepath TYPE  zfileuplo-fpath,
      f_num(16)   TYPE c,
      it_custom   TYPE TABLE OF zfileuplo,
      wa_custom   TYPE zfileuplo.

DATA : it_fldcat  TYPE lvc_t_fcat,
       wa_fldcat  TYPE lvc_s_fcat,
       it_toolbar TYPE TABLE OF stb_button,
       wa_toolbar TYPE stb_button.

DATA : container TYPE REF TO cl_gui_custom_container,
       grid      TYPE REF TO cl_gui_alv_grid.

CLASS handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS : handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_object,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid IMPORTING e_ucomm.

ENDCLASS.

CLASS handle_events IMPLEMENTATION.

  METHOD handle_toolbar .

    wa_toolbar-function  = 'UPLOAD'.
    wa_toolbar-butn_type = 0.
    wa_toolbar-icon      = '@Y5@'.
    wa_toolbar-quickinfo = 'Upload'.
    APPEND wa_toolbar TO it_toolbar.

    APPEND LINES OF it_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.


  METHOD handle_user_command.

    DATA: lt_rows  TYPE lvc_t_row,
          wa_row   TYPE lvc_s_row,
          lv_index TYPE i.

    CASE e_ucomm.
      WHEN 'UPLOAD'.
        CALL METHOD grid->get_selected_rows
          IMPORTING
            et_index_rows = lt_rows.

        IF lt_rows IS INITIAL.
          MESSAGE 'Please select a flight row to upload the file.' TYPE 'E'.
          RETURN.
        ENDIF.

        READ TABLE lt_rows INTO wa_row INDEX 1.
        IF sy-subrc = 0.
          lv_index = wa_row-index.
          READ TABLE it_ft INTO wa_ft INDEX lv_index.
          IF sy-subrc = 0.

            CALL SCREEN 0200.
          ELSE.
            MESSAGE 'Error reading selected row data.' TYPE 'E'.
          ENDIF.
        ELSE.
          MESSAGE 'No row selected. Please select a row.' TYPE 'E'.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.

DATA : event_handler TYPE REF TO handle_events.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_car FOR scarr-carrid.
SELECTION-SCREEN END OF BLOCK b1.

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
  SELECT a~carrid b~airport c~cityfrom c~cityto d~fldate d~price d~currency d~paymentsum
    FROM scarr AS a INNER JOIN scounter AS b ON a~carrid = b~carrid
                    INNER JOIN spfli AS c ON a~carrid = c~carrid
                    INNER JOIN sflight AS d ON  a~carrid = d~carrid
    INTO CORRESPONDING FIELDS OF TABLE it_ft WHERE a~carrid IN s_car.
ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF-01'.
  SET TITLEBAR 'T-01'.

  IF container IS INITIAL.

    CREATE OBJECT container
      EXPORTING
        container_name = 'ZCONTAINER'.

    CREATE OBJECT grid
      EXPORTING
        i_parent = container.

    CREATE OBJECT event_handler.

    SET HANDLER event_handler->handle_toolbar FOR grid.
    SET HANDLER event_handler->handle_user_command FOR grid.

    PERFORM field_cat.
    PERFORM display_data.

  ENDIF.



ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 0.
  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Form field_cat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM field_cat .

  wa_fldcat-fieldname = 'CARRID'.
  wa_fldcat-seltext = 'C ID'.
  wa_fldcat-reptext = 'ID'.
  wa_fldcat-outputlen = 8.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'AIRPORT'.
  wa_fldcat-seltext = 'AIRPORT'.
  wa_fldcat-reptext = 'AIRPORT'.
  wa_fldcat-outputlen = 8.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'CITYFROM'.
  wa_fldcat-seltext = 'CITY FROM'.
  wa_fldcat-reptext = 'FROM'.
  wa_fldcat-outputlen = 15.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'CITYTO'.
  wa_fldcat-seltext = 'CITY TO'.
  wa_fldcat-reptext = 'TO'.
  wa_fldcat-outputlen = 15.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'FLDATE'.
  wa_fldcat-seltext = 'DATE'.
  wa_fldcat-reptext = 'FLIGHT DATE'.
  wa_fldcat-outputlen = 12.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'PRICE'.
  wa_fldcat-seltext = 'PRICE'.
  wa_fldcat-reptext = 'PRICE'.
  wa_fldcat-outputlen = 8.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'CURRENCY'.
  wa_fldcat-seltext = 'CURRENCY'.
  wa_fldcat-reptext = 'CURRENCY'.
  wa_fldcat-outputlen = 8.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'PAYMENTSUM'.
  wa_fldcat-seltext = 'PAYMENT SUM'.
  wa_fldcat-reptext = 'SUM'.
  wa_fldcat-outputlen = 15.
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
*     i_buffer_active               =
*     i_bypassing_buffer            =
*     i_consistency_check           =
*     i_structure_name              =
*     is_variant                    =
*     i_save    =
*     i_default = 'X'
*     is_layout =
*     is_print  =
*     it_special_groups             =
*     it_toolbar_excluding          =
*     it_hyperlink                  =
*     it_alv_graphics               =
*     it_except_qinfo               =
*     ir_salv_adapter               =
    CHANGING
      it_outtab       = it_ft
      it_fieldcatalog = it_fldcat
*     it_sort         =
*     it_filter       =
*  EXCEPTIONS
*     invalid_parameter_combination = 1
*     program_error   = 2
*     too_many_lines  = 3
*     others          = 4
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'PF-02'.
  SET TITLEBAR 'xxx'.
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
      IF lv_filepath IS NOT INITIAL.
        wa_custom-fnum = f_num.
        wa_custom-airport = wa_ft-airport.
        wa_custom-fpath = lv_filepath.
        APPEND wa_custom TO it_custom.

        INSERT zfileuplo FROM TABLE it_custom.
        IF sy-subrc = 0.
          MESSAGE 'File path saved successfully.' TYPE 'S'.
        ELSE.
          MESSAGE 'Error saving file path.' TYPE 'E'.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ZAAA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE zaaa INPUT.

  IF sy-subrc IS INITIAL.

  ENDIF.

ENDMODULE.