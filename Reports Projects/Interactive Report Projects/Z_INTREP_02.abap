*&---------------------------------------------------------------------*
*& Report Z_INTREP_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_intrep_02.

TABLES : zemp_attendance.

TYPES :ty_attendance TYPE zemp_attendance.

DATA : it_attendance TYPE TABLE OF ty_attendance,
       wa_attendance TYPE ty_attendance.

DATA : present TYPE i VALUE 0,
       absent  TYPE i VALUE 0,
       leave   TYPE i VALUE 0.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_id FOR zemp_attendance-emp_id.

  PARAMETERS : p_d1 RADIOBUTTON GROUP grp DEFAULT 'X' USER-COMMAND rad,
               p_d2 RADIOBUTTON GROUP grp.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS : p_id   TYPE zemp_attendance-emp_id,
               p_date TYPE zemp_attendance-att_date,
               p_stat TYPE zemp_attendance-status,
               p_hrs  TYPE zemp_attendance-hours_worked.
SELECTION-SCREEN END OF BLOCK b2.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN INTO DATA(screen_wa).
    IF screen_wa-group1 = 'B2'.
      screen_wa-active = p_d2.
      MODIFY SCREEN FROM screen_wa.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.

  IF p_d1 IS NOT INITIAL.
    PERFORM fetch_data.
    PERFORM summary.
    PERFORM display_data.
  ELSEIF p_d2 IS NOT INITIAL.
    PERFORM insert_data.
  ENDIF.


*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data .
  SELECT * FROM zemp_attendance INTO CORRESPONDING FIELDS OF TABLE it_attendance WHERE emp_id IN s_id.
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

  WRITE : / 'Employee ID ' ,20 'Attendance Date',40 'Status',60 'Hours Worked'.
  ULINE.

  LOOP AT it_attendance INTO wa_attendance.
    WRITE : / wa_attendance-emp_id ,20 wa_attendance-att_date ,40 wa_attendance-status
     ,60 wa_attendance-hours_worked.

    CASE wa_attendance-status.
      WHEN 'P'.
        WRITE : 80 icon_green_light AS ICON COLOR COL_POSITIVE.  " Green for Present
      WHEN 'A'.
        WRITE : 80 icon_red_light AS ICON COLOR COL_NEGATIVE.    " Red for Absent
      WHEN 'L'.
        WRITE : 80 icon_yellow_light AS ICON COLOR COL_TOTAL.    " Yellow for Leave
    ENDCASE.
  ENDLOOP.

  ULINE.

  WRITE : / 'SUMMARY' COLOR 4.
  ULINE.
  WRITE : / 'Present :' , present LEFT-JUSTIFIED,
          / 'Absent : ',absent LEFT-JUSTIFIED,
          / 'Leave : ', leave LEFT-JUSTIFIED.
  ULINE.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form summary
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM summary .
  LOOP AT it_attendance INTO wa_attendance.
    CASE wa_attendance-status.
      WHEN 'P'.
        present = present + 1.
      WHEN 'A'.
        absent = absent + 1.
      WHEN 'L'.
        leave = leave + 1.
    ENDCASE.
  ENDLOOP.
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
  CLEAR wa_attendance.

  wa_attendance-emp_id =  p_id .
  wa_attendance-att_date = p_date.
  wa_attendance-status = p_stat.
  wa_attendance-hours_worked = p_hrs.

  INSERT zemp_attendance FROM wa_attendance.
  IF sy-subrc = 0.
    WRITE: / 'Data inserted successfully'.
  ELSE.
    WRITE: / 'Error inserting data'.
  ENDIF.

ENDFORM.

TOP-OF-PAGE.
  WRITE : 'EMPLOYEE ATTENDANCE DETAIL' COLOR 3 .
  ULINE.
