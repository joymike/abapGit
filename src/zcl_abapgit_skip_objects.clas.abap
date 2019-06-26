CLASS zcl_abapgit_skip_objects DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      skip_sadl_generated_objects
        IMPORTING
          it_tadir        TYPE zif_abapgit_definitions=>ty_tadir_tt
          ii_log          TYPE REF TO zif_abapgit_log OPTIONAL
        RETURNING
          VALUE(rt_tadir) TYPE zif_abapgit_definitions=>ty_tadir_tt.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      has_sadl_superclass
        IMPORTING
          is_class         TYPE zif_abapgit_definitions=>ty_tadir
        RETURNING
          VALUE(rv_return) TYPE abap_bool.

ENDCLASS.



CLASS ZCL_ABAPGIT_SKIP_OBJECTS IMPLEMENTATION.


  METHOD has_sadl_superclass.

    DATA: li_oo_functions TYPE REF TO zif_abapgit_oo_object_fnc,
          lv_class_name   TYPE seoclsname,
          lv_superclass   TYPE seoclsname.


    li_oo_functions = zcl_abapgit_oo_factory=>make( is_class-object ).
    lv_class_name = is_class-obj_name.
    lv_superclass = li_oo_functions->read_superclass( lv_class_name ).
    IF lv_superclass = 'CL_SADL_GTK_EXPOSURE_MPC'.
      rv_return = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD skip_sadl_generated_objects.
    DATA: ls_tadir_class     LIKE LINE OF rt_tadir,
          ls_tadir           LIKE LINE OF rt_tadir,
          lt_lines_to_delete TYPE zif_abapgit_definitions=>ty_tadir_tt.

    rt_tadir = it_tadir.
    LOOP AT it_tadir INTO ls_tadir WHERE object = 'DDLS'.
      LOOP AT rt_tadir INTO ls_tadir_class
          WHERE object = 'CLAS' AND obj_name CS ls_tadir-obj_name.
        IF has_sadl_superclass( ls_tadir_class ) = abap_true.
          APPEND ls_tadir_class TO lt_lines_to_delete.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM lt_lines_to_delete.
    LOOP AT lt_lines_to_delete INTO ls_tadir_class.
      DELETE TABLE rt_tadir FROM ls_tadir_class.
      IF ii_log IS BOUND.
        ii_log->add(
          iv_msg = |{ ls_tadir_class-obj_name } skipped: generated by SADL|
          iv_type = 'W' ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
