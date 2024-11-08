*&---------------------------------------------------------------------*
*& Report Z_ALVPRO_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_alvpro_02.

TABLES: ztimesheet.

TYPE-POOLS: slis.

TYPES: BEGIN OF ty_summary,
         projcode   TYPE ztimesheet-projcode,
         weekending TYPE ztimesheet-weekending,
         totalhours TYPE ztimesheet-totalhours,
       END OF ty_summary.

DATA: it_tstable TYPE TABLE OF ztimesheet,
      wa_tstable TYPE ztimesheet,
      it_summary TYPE TABLE OF ty_summary,
      wa_summary TYPE ty_summary,
      it_fldcat  TYPE slis_t_fieldcat_alv,
      wa_fldcat  TYPE slis_fieldcat_alv,
      it_events  TYPE slis_t_event,
      wa_events  TYPE slis_alv_event.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_id FOR ztimesheet-emplid.

  PARAMETERS : p01 RADIOBUTTON GROUP grp1,
               p02 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM fetch_data.
  IF p01 IS NOT INITIAL.
    PERFORM fldcat2_data.
    PERFORM show2_data.
  ELSEIF p02 IS NOT INITIAL.
    PERFORM summarize_data.
    PERFORM fldcat_data.
    PERFORM show_data.
  ENDIF.


*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
FORM fetch_data.
  SELECT * FROM ztimesheet INTO TABLE it_tstable WHERE emplid IN s_id.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form summarize_data
*&---------------------------------------------------------------------*
FORM summarize_data.
  DATA: lt_temp TYPE TABLE OF ztimesheet.


  SORT it_tstable BY projcode weekending.
  LOOP AT it_tstable INTO wa_tstable.
    AT NEW projcode.
      CLEAR wa_summary.
      wa_summary-projcode = wa_tstable-projcode.
    ENDAT.
    AT NEW weekending.
      wa_summary-weekending = wa_tstable-weekending.
      wa_summary-totalhours = 0.
    ENDAT.


    wa_summary-totalhours = wa_summary-totalhours + wa_tstable-totalhours.


    AT END OF weekending.
      APPEND wa_summary TO it_summary.
    ENDAT.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form fldcat_data
*&---------------------------------------------------------------------*
FORM fldcat_data.

  CLEAR wa_fldcat.
  wa_fldcat-fieldname = 'PROJCODE'.
  wa_fldcat-tabname   = 'IT_SUMMARY'.
  wa_fldcat-seltext_m = 'Project Code'.
  APPEND wa_fldcat TO it_fldcat.

  CLEAR wa_fldcat.
  wa_fldcat-fieldname = 'WEEKENDING'.
  wa_fldcat-tabname   = 'IT_SUMMARY'.
  wa_fldcat-seltext_m = 'Week Ending'.
  APPEND wa_fldcat TO it_fldcat.

  CLEAR wa_fldcat.
  wa_fldcat-fieldname = 'TOTALHOURS'.
  wa_fldcat-tabname   = 'IT_SUMMARY'.
  wa_fldcat-seltext_m = 'Total Hours'.
  wa_fldcat-do_sum    = 'X'.
  APPEND wa_fldcat TO it_fldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form show_data
*&---------------------------------------------------------------------*
FORM show_data.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = 'F_TOP_OF_PAGE'
      it_fieldcat            = it_fldcat
    TABLES
      t_outtab               = it_summary
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form fldcat2_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fldcat2_data .

  wa_fldcat-fieldname = 'EMPLID'.
  wa_fldcat-tabname = 'it_tstable'.
  wa_fldcat-seltext_m = 'Employee ID'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'EMPLNAME'.
  wa_fldcat-tabname = 'it_tstable'.
  wa_fldcat-seltext_m = 'Employee Name'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'PROJCODE'.
  wa_fldcat-tabname = 'it_tstable'.
  wa_fldcat-seltext_m = 'Project Code'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'WEEKENDING'.
  wa_fldcat-tabname = 'it_tstable'.
  wa_fldcat-seltext_m = 'Week Ending'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'TOTALHOURS'.
  wa_fldcat-tabname = 'it_tstable'.
  wa_fldcat-seltext_m = 'Total Hours'.
  APPEND wa_fldcat TO it_fldcat.

  wa_fldcat-fieldname = 'STATUS'.
  wa_fldcat-tabname = 'it_tstable'.
  wa_fldcat-seltext_m = 'Status'.
  APPEND wa_fldcat TO it_fldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form show2_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show2_data .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = 'F_TOP_OF_PAGE'
      it_fieldcat            = it_fldcat
    TABLES
      t_outtab               = it_tstable
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

FORM f_top_of_page.

  DATA : it_lheader TYPE slis_t_listheader,
         wa_lheader TYPE slis_listheader.

  wa_lheader-typ  = 'H'.
  wa_lheader-info = 'Employee Time Sheet'.
  APPEND wa_lheader TO it_lheader.

  wa_lheader-typ  = 'A'.
  wa_lheader-info = sy-datum.
  APPEND wa_lheader TO it_lheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_lheader.

ENDFORM.