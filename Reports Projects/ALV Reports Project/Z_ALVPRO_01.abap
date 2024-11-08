*  &---------------------------------------------------------------------*
*  & Report Z_ALVPRO_01
*  &---------------------------------------------------------------------*
*  &
*  &---------------------------------------------------------------------*
  REPORT z_alvpro_01.

  TABLES : zsomain.

  TYPE-POOLS : slis.
  INCLUDE <icon>.

  TYPES : BEGIN OF ty_so,
            custid        TYPE zsomain-custid,
            custname      TYPE zsomain-custname,
            soid          TYPE zsomain-soid,
            orderdate     TYPE zsomain-orderdate,
            itemid        TYPE zsomain-itemid,
            materialid    TYPE zsomain-materialid,
            materialdesc  TYPE zsomain-materialdesc,
            price         TYPE zsomain-price,
            currency      TYPE zsomain-currency,
            divison       TYPE zsomain-divison,
            orderstatus   TYPE zsomain-orderstatus,
            traffic_light TYPE icon_d,
          END OF ty_so.

  DATA : it_so           TYPE TABLE OF ty_so, "Internal table Declaration
         wa_so           TYPE ty_so,
         it_fldcat       TYPE slis_t_fieldcat_alv, "fldcat Declaration
         wa_fldcat       TYPE slis_fieldcat_alv,
         it_events       TYPE slis_t_event, "Events Declaration
         wa_events       TYPE slis_alv_event,
         division_filter TYPE zsomain-divison.


  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
    SELECT-OPTIONS : p_id FOR zsomain-custid.
  SELECTION-SCREEN END OF BLOCK b1.

  START-OF-SELECTION.
    PERFORM fetch_data.
    PERFORM fldcat_data.
    PERFORM fill_events.
    PERFORM show_data.


*  &---------------------------------------------------------------------*
*  & Form fetch_data
*  &---------------------------------------------------------------------*
*  & text
*  &---------------------------------------------------------------------*
*  & -->  p1        text
*  & <--  p2        text
*  &---------------------------------------------------------------------*
  FORM fetch_data .
    CLEAR it_so.

    IF division_filter IS INITIAL.
      SELECT * FROM zsomain INTO CORRESPONDING FIELDS OF TABLE it_so WHERE custid IN p_id.
    ELSE.
      SELECT * FROM zsomain INTO CORRESPONDING FIELDS OF TABLE it_so
        WHERE custid IN p_id
        AND divison = division_filter.
    ENDIF.

    LOOP AT it_so INTO wa_so.
      CASE wa_so-orderstatus.
        WHEN 'COMPLETED'.
          wa_so-traffic_light = icon_green_light.
        WHEN 'PENDING'.
          wa_so-traffic_light = icon_yellow_light.
        WHEN 'CANCELED'.
          wa_so-traffic_light = icon_red_light.
        WHEN OTHERS.
          wa_so-traffic_light = icon_red_light.
      ENDCASE.
      MODIFY it_so FROM wa_so.
    ENDLOOP.
  ENDFORM.

*  &---------------------------------------------------------------------*
*  & Form fldcat_data
*  &---------------------------------------------------------------------*
*  & text
*  &---------------------------------------------------------------------*
*  & -->  p1        text
*  & <--  p2        text
*  &---------------------------------------------------------------------*
  FORM fldcat_data .

    wa_fldcat-fieldname = 'CUSTID'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Customer ID'.
    APPEND wa_fldcat TO it_fldcat.

    wa_fldcat-fieldname = 'CUSTNAME'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Customer Name'.
    APPEND wa_fldcat TO it_fldcat.

    wa_fldcat-fieldname = 'SOID'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Sales Order ID'.
    APPEND wa_fldcat TO it_fldcat.

    wa_fldcat-fieldname = 'ORDERDATE'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Order Date'.
    APPEND wa_fldcat TO it_fldcat.

    wa_fldcat-fieldname = 'ITEMID'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Item ID'.
    APPEND wa_fldcat TO it_fldcat.

    wa_fldcat-fieldname = 'MATERIALID'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Material ID'.
    APPEND wa_fldcat TO it_fldcat.

    wa_fldcat-fieldname = 'MATERIALDESC'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Material Description'.
    APPEND wa_fldcat TO it_fldcat.

    wa_fldcat-fieldname = 'PRICE'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Price'.
    APPEND wa_fldcat TO it_fldcat.

    wa_fldcat-fieldname = 'CURRENCY'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Currency'.
    APPEND wa_fldcat TO it_fldcat.

    wa_fldcat-fieldname = 'DIVISON'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Division'.
    wa_fldcat-hotspot = 'X'.
    APPEND wa_fldcat TO it_fldcat.

    wa_fldcat-fieldname = 'ORDERSTATUS'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Order Status'.
    APPEND wa_fldcat TO it_fldcat.

    wa_fldcat-fieldname = 'TRAFFIC_LIGHT'.
    wa_fldcat-tabname = 'it_so'.
    wa_fldcat-seltext_m = 'Status Indicator'.
    wa_fldcat-icon = 'X'.
    APPEND wa_fldcat TO it_fldcat.

  ENDFORM.

*  &---------------------------------------------------------------------*
*  & Form fill_events
*  &---------------------------------------------------------------------*
*  & text
*  &---------------------------------------------------------------------*
*  & -->  p1        text
*  & <--  p2        text
*  &---------------------------------------------------------------------*
  FORM fill_events .
    CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
*     EXPORTING
*       I_LIST_TYPE           = 0
      IMPORTING
        et_events = it_events.
    IF sy-subrc  = 0.
      READ TABLE it_events INTO wa_events WITH KEY name = 'TOP_OF_PAGE'.
      IF sy-subrc = 0.
        wa_events-form = 'f_top_of_page'.
        MODIFY it_events FROM wa_events INDEX sy-tabix.
      ENDIF.

      READ TABLE it_events INTO wa_events WITH KEY name = 'USER_COMMAND'.
      IF sy-subrc = 0.
        wa_events-form = 'handle_user_command'.
        MODIFY it_events FROM wa_events INDEX sy-tabix.
      ENDIF.
    ENDIF.
*     EXCEPTIONS
*       LIST_TYPE_WRONG       = 1
*       OTHERS    = 2
    .

    IF sy-subrc <> 0.
*   Implement suitable error handling here
    ENDIF.

  ENDFORM.

  FORM handle_user_command USING p_ucomm TYPE sy-ucomm p_selfield TYPE slis_selfield.
    DATA: lv_division TYPE zsomain-divison.

    IF p_ucomm = '&IC1' AND p_selfield-fieldname = 'DIVISON'.
      lv_division = p_selfield-value.
      division_filter = lv_division.

      PERFORM fetch_data.
      PERFORM show_data.
    ENDIF.
  ENDFORM.

  FORM f_top_of_page.

    DATA : it_lheader TYPE slis_t_listheader,
           wa_lheader TYPE slis_listheader.

    wa_lheader-typ  = 'H'.
    wa_lheader-info = 'Sales Order Table Report'.
    APPEND wa_lheader TO it_lheader.

    wa_lheader-typ  = 'A'.
    wa_lheader-info = sy-datum.
    APPEND wa_lheader TO it_lheader.

    CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
      EXPORTING
        it_list_commentary = it_lheader.

  ENDFORM.

*  &---------------------------------------------------------------------*
*  & Form show_data
*  &---------------------------------------------------------------------*
*  & text
*  &---------------------------------------------------------------------*
*  & -->  p1        text
*  & <--  p2        text
*  &---------------------------------------------------------------------*

  FORM show_data .
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
*       I_INTERFACE_CHECK       = ' '
*       I_BYPASSING_BUFFER      = ' '
*       I_BUFFER_ACTIVE         = ' '
        i_callback_program      = sy-repid
*       I_CALLBACK_PF_STATUS_SET          = ' '
        i_callback_user_command = 'HANDLE_USER_COMMAND'
        i_callback_top_of_page  = 'F_TOP_OF_PAGE'
*       I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*       I_CALLBACK_HTML_END_OF_LIST       = ' '
*       I_STRUCTURE_NAME        =
*       I_BACKGROUND_ID         = ' '
*       I_GRID_TITLE            =
*       I_GRID_SETTINGS         =
*       IS_LAYOUT               =
        it_fieldcat             = it_fldcat
*       IT_EXCLUDING            =
*       IT_SPECIAL_GROUPS       =
*       IT_SORT                 =
*       IT_FILTER               =
*       IS_SEL_HIDE             =
*       I_DEFAULT               = 'X'
*       I_SAVE                  = ' '
*       IS_VARIANT              =
*       IT_EVENTS               =
*       IT_EVENT_EXIT           =
*       IS_PRINT                =
*       IS_REPREP_ID            =
*       I_SCREEN_START_COLUMN   = 0
*       I_SCREEN_START_LINE     = 0
*       I_SCREEN_END_COLUMN     = 0
*       I_SCREEN_END_LINE       = 0
*       I_HTML_HEIGHT_TOP       = 0
*       I_HTML_HEIGHT_END       = 0
*       IT_ALV_GRAPHICS         =
*       IT_HYPERLINK            =
*       IT_ADD_FIELDCAT         =
*       IT_EXCEPT_QINFO         =
*       IR_SALV_FULLSCREEN_ADAPTER        =
*       O_PREVIOUS_SRAL_HANDLER =
      TABLES
        t_outtab                = it_so.

  ENDFORM.