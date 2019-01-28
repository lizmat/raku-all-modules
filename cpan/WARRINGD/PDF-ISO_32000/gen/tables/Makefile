## Makefile to disseminate tables from PDF Specification
## as referenced throughout the Perl 6 PDF Tool-chain.
## Used for documentation and automated cross-checking
## Notes:
## - Tables aren't mapped to Outlines (outline dictionaries don't have a
##   /SE entry to cross reference the struct-tree).
## - Need to be dug out of the spec either by breadth-first search of the struct-tree,
##   or page-by-page.
## - I've chosen page-by-page. Easier to reference the spec this way.
## - Doing them one at a time. Not fast.
## - Would be good to generate them all in one run,
##   but that takes a lot of memory.
## - Could batch a few at a time, with a bit more work
## - But only need to do this occasionally, anyway

PDF_SPEC=../../src/PDF32000_2008.pdf
define table_to_html
    (echo '<Html><Head/><Body>' && USE_PDF_NATIVE=1 perl6 ../../bin/pdf-struct-dump.p6 --/atts --max-depth=8 --search-tag=Table --page=$(1) $(2) $(PDF_SPEC) && echo '</Body></Html>')
endef

all : tables
tables : White-space_characters.html Delimiter_characters.html String_escape_sequences.html Literal_name_examples.html Stream_common_entries.html Standard_filters.html Typical_LZW_encoding_sequence.html LZW_and_Flate_filter_entries.html PNG_predictor_algorithms.html Predictor_values.html \
CCITTFax_filter_entries.html JBIG2_filter_entries.html DCT_filter_entries.html Crypt_filter_entries.html File_trailer_entries.html Object_stream_entries.html Cross_reference_stream_entries.html Cross_reference_stream_fields.html Hybrid-reference_entries.html Encryption_common_entries.html Additional_encryption_entries.html User_access_permissions.html Public_key_security_handler_additional_entries.html Public_key_security_handler_user_access_permissions.html Crypt_filter_common_entries.html Standard_crypt_filter_names.html Crypt_filter_public-key_additional_entries.html Catalog_entries.html Pages_entries.html Page_entries.html Catalog_Name_tree_entries.html Compatibility_operators.html Resource_entries.html PDF_data_types.html String_object_data_types.html Name_tree_node_entries.html Number_tree_node_entries.html Function_common_entries.html Type_0_Function_entries.html Type_2_Function_entries.html Type_3_Function_entries.html Type_4_Function_operators.html File_specification_examples.html File_specification_entries.html Embedded_file_stream_entries.html Embedded_file_parameter_entries.html MacOS_file_information_entries.html Collection_item_entries.html Collection_subitem_entries.html Developer_extensions_entries.html Operator_categories.html Device_independent_graphics_state.html Device_dependent_graphics_state.html Line_cap_styles.html Line_join_styles.html Line_dash_examples.html Graphics_state_operators.html Graphics_state_entries.html Path_construction_operators.html Path_painting_operators.html Clipping_path_operators.html Colour_space_families.html CalGray_colour_space_entries.html CalRGB_colour_space_entries.html Lab_colour_space_entries.html ICC_profile_entries.html ICC_profile_versions.html ICC_profile_types.html ICC_profile_ranges.html Rendering_intents.html DeviceN_colour_space_attributes.html DeviceN_process_entries.html DeviceN_mixing_hints_entries.html Colour_operators.html Type_1_Pattern_entries.html Type_2_Pattern_entries.html Shading_operator.html Shading_common_entries.html Type_1_Shading_entries.html Type_2_Shading_entries.html Type_3_Shading_entries.html Type_4_Shading_entries.html Type_5_Shading_entries.html Type_6_Shading_entries.html Data_values_in_a_coons_patch_mesh.html Data_values_in_a_tensor_product_patch_mesh.html XObject_operator.html Postscript_XObject_entries.html Image_entries.html Default_decode_arrays.html Alternate_Image_entries.html Inline_Image_operators.html Inline_Image_entries.html Inline_Image_additional_operators.html Type_1_Form_entries.html Group_Attributes_common_entries.html Reference_entries.html Optional_Content_Group_entries.html Optional_Content_Group_Membership_entries.html Optional_Content_Group_Properties_entries.html Optional_Content_Configuration_entries.html Optional_Content_Group_Usage_entries.html Optional_Content_Group_Application_entries.html Text_state_parameters.html Text_state_operators.html Text_rendering_modes.html Text_object_operators.html Text_position_operators.html Text_showing_operators.html Font_types.html Type_1_Font_entries.html Type_3_Font_entries.html Type_3_Font_operators.html Encoding_entries.html MacOS_encoding_differences.html CIDSystemInfo_entries.html CIDFont_entries.html CJK_CMap_names.html Character_collections_for_CMaps.html CMap_stream_entries.html Type_0_Font_entries.html Font_descriptor_common_entries.html Font_descriptor_flags.html CIDFont_descriptor_additional_entries.html Glyph_classes_in_CJK_fonts.html Embedded_font_organisation.html Embedded_font_stream_additional_entries.html \
Predefined_spot_functions.html Halftone_types.html Type_1_halftone_entries.html Type_6_halftone_entries.html Type_10_halftone_entries.html Type_16_halftone_entries.html Type_5_halftone_entries.html Basic_compositing_variables.html Standard_separable_blend_modes.html Standard_nonseparable_blend_modes.html Source_shape_and_opacity_formula_variables.html Result_shape_and_opacity_formula_variables.html Revised_basic_compositing_formula_variables.html Arguments_and_results_of_group_compositing_function.html Variables_used_in_the_group_compositing_formulas.html Variables_used_in_the_page_group_compositing_formulas.html Soft-mask_entries.html Soft-mask_image_restrictions.html Soft-mask_image_additional_entries.html Transparency_group_additional_entries.html Overprinting_behavior_in_the_opaque_imaging_model.html Overprinting_behavior_in_the_transparent_imaging_model.html Viewer_preferences_entries.html Destination_syntax.html Outline_entries.html Outline_item_entries.html \
Outline_item_flags.html Collection_entries.html Collection_schema_entries.html Collection_field_entries.html Collection_sort_entries.html Page_label_entries.html Thread_entries.html Bead_entries.html Transition_entries.html Navigation_node_entries.html Annotation_common_entries.html Annotation_flags.html Border_style_entries.html Border_effect_entries.html Appearance_entries.html Annotation_types.html Annotation_markup_additional_entries.html Annotation_states.html Text_annotation_additional_entries.html Link_annotation_additional_entries.html \
Free_text_annotation_additional_entries.html Line_annotation_additional_entries.html Line_ending_styles.html Square_or_circle_annotation_additional_entries.html Polygon_or_polyline_annotation_additional_entries.html Text_markup_annotation_additional_entries.html Caret_annotation_additional_entries.html Rubber_stamp_annotation_additional_entries.html Ink_annotation_additional_entries.html Popup_annotation_additional_entries.html File_attachment_annotation_additional_entries.html Sound_annotation_additional_entries.html Movie_annotation_additional_entries.html Screen_annotation_additional_entries.html Widget_annotation_additional_entries.html Appearance_characteristics_entries.html Watermark_annotation_additional_entries.html Fixed_print_entries.html Redaction_annotation_additional_entries.html Action_common_entries.html Annotation_additional_actions_entries.html Page_additional_actions_entries.html Form_additional_actions_entries.html Catalog_additional_actions_entries.html Action_types.html \
Goto_action_additional_entries.html Remote_goto_action_additional_entries.html Embedded_goto_action_additional_entries.html Target_entries.html Launch_action_additional_entries.html Windows_launch_parameters_entries.html Thread_action_additional_entries.html URI_action_additional_entries.html URI_entries.html Sound_action_additional_entries.html Movie_action_additional_entries.html Hide_action_additional_entries.html Named_actions.html Named_action_additional_entries.html Set-OCG-state_action_additional_entries.html Rendition_action_additional_entries.html Transition_action_additional_entries.html Goto_3D_view_action_additional_entries.html JavaScript_action_additional_entries.html Interactive_form_entries.html Signature_flags.html Field_common_entries.html Field_flags.html Variable_text_field_entries.html XHTML_rich_text_string_elements.html Body_element.html CSS2_style_attributes.html Button_field_flags.html Check_box_and_radio_button_additional_entries.html Text_field_flags.html Text_field_additional_entries.html Choice_field_flags.html Choice_field_additional_entries.html Signature_field_entries.html Signature_field_lock_entries.html Signature_field_seed_value_entries.html Certificate_seed_value_entries.html Submit_form_action_entries.html Submit_form_action_flags.html Reset_form_action_entries.html Reset_form_action_flags.html Import-data_action_additional_entries.html FDF_trailer_entries.html FDF_catalog_entries.html FDF_dictionary_entries.html Embedded_file_stream_entries_FDF_additional.html JavaScript_entries.html FDF_field_entries.html  \
Icon_fit_entries.html FDF_page_entries.html FDF_template_entries.html FDF_named_page_reference_entries.html FDF_annotation_additional_entries.html Signature_entries.html Signature_reference_entries.html DocMDP_transform_entries.html UR_transform_entries.html FieldMDP_transform_entries.html SubFilter_value_algorithm_support.html Permissions_entries.html Legal_attestation_entries.html Viewport_entries.html Measure_entries.html Rectilinear_measure_additional_entries.html Number_format_entries.html Requirement_common_entries.html Requirement_handler_entries.html Rendition_common_entries.html Rendition_MH-BE_entries.html Rendition_criteria_entries.html Minimum_bit_depth_entries.html Minimum_screen_size_entries.html Media_rendition_entries.html Selector_rendition_entries.html Media_clip_common_entries.html Media_clip_data_entries.html Media_permissions_entries.html Media_clip_data_MH-BE_entries.html Media_clip_section_entries.html Media_clip_section_MH-BE_entries.html Media_play_parameters_entries.html Media_play_parameters_MH-BE-entries.html \
Media_duration_entries.html Media_screen_parameters_entries.html Media_screen_parameters_MH-BE_entries.html Floating_window_parameter_entries.html Media_offset_common_entries.html Media_offset_time_entries.html Media_offset_frame_entries.html Media_offset_marker_entries.html Timespan_entries.html Media_players_entries.html Media_player_info_entries.html Software_identifier_entries.html Monitor_specifier_values.html Sound_object_entries.html Movie_entries.html Movie_activation_entries.html Slideshow_entries.html Three-D_annotation_entries.html Three-D_activation_entries.html Three-D_stream_entries.html Three-D_animation_style_entries.html Animation_styles.html Three-D_reference_entries.html Three-D_view_entries.html Projection_entries.html Three-D_background_entries.html Render_mode_entries.html Render_modes.html Three-D_lighting_entries.html Three-D_lighting_styles.html Three-D_cross_section_entries.html \
Three-D_node_entries.html Three-D_external_data_entries.html Predefined_procedure_set.html Metadata_stream_additional_entries.html Metadata_additional_entries.html Info_entries.html Page-piece_entries.html Data_entries.html Marked_content_operators.html Mark_information_entries.html Structure_tree_root_entries.html Structure_tree_element_entries.html Marked_content_reference_entries.html Object_reference_entries.html Structure_element_access_additional_entries.html Attribute_object_entries.html Attribute_object_for_user_properties_entries.html User_property_entries.html Artifact_entries.html Font_characteristic_derivation.html Font_selector_attributes.html \
Standard_structure_types_for_grouping_elements.html Block_level_structure_elements.html Standard_structure_types_for_paragraphlike_elements.html Standard_structure_types_for_list_elements.html Standard_structure_types_for_table_elements.html Standard_structure_types_for_inline-level_elements.html Standard_structure_types_for_Ruby_and_Warichu_elements.html Standard_structure_types_for_illustration_elements.html Standard_attribute_owners.html Standard_layout.html Standard_layout_structure_type_attributes.html Standard_layout_block-level_structure_element_attributes.html Standard_inline-level_structure_element_attributes.html Standard_column_attributes.html Standard_list_attributes.html \
Web_Capture_information_entries.html Characters_with_special_meanings.html Web_Capture_content_sets_entries.html Web_Capture_page_set_additional_entries.html Web_Capture_image_set_entries.html PrintField_attributes.html Standard_table_attributes.html \
Source_information_entries.html URL_alias_entries.html Web_capture_command_entries.html Web_capture_command_flags.html Web_capture_command_settings_entries.html Box_colour_information_entries.html Box_style_entries.html Printers_mark_annotation_entries.html Printers_mark_form_entries.html Separation_entries.html Output_intent_entries.html Trap_network_annotation_entries.html Trap_network_appearance_stream_entries.html OPI_version_entries.html OPI_version_1_3_entries.html OPI_version_2_0_entries.html \
PDF_content_stream_operators.html Architectural_limits.html Latin-text_encodings.html PDFDocEncoding_Character_Set.html Linearization_parameter_entries.html Standard_hint_tables.html Page_offset_hint_tables-header_section.html Page_offset_hint_tables-per_page_entry.html Shared_object_hint_table-header_section.html Shared_object_hint_table-shared_object_group_entry.html Thumbnail_hint_table-header_section.html Thumbnail_hint_table-per_page_entry.html Generic_hint_table.html Extended_generic_hint_table.html Embedded_file_stream_hint_table-header_section.html Embedded_file_stream_hint_table-per_file_stream.html

# Table 1
White-space_characters.html :
	$(call table_to_html,20) > $@

# Table 2
Delimiter_characters.html :
	$(call table_to_html,21) > $@

# Table 3
String_escape_sequences.html :
	$(call table_to_html,23) > $@

# Table 4
Literal_name_examples.html :
	$(call table_to_html,25) > $@

# Table 5
Stream_common_entries.html :
	$(call table_to_html,28) > $@

# Table 6
Standard_filters.html :
	$(call table_to_html,31) > $@

# Table 7
Typical_LZW_encoding_sequence.html :
	$(call table_to_html,34) > $@

# Table 8
LZW_and_Flate_filter_entries.html :
	$(call table_to_html,35) > $@

# Table 9
PNG_predictor_algorithms.html :
	$(call table_to_html,36) > $@

# Table 10
Predictor_values.html :
	$(call table_to_html,37) > $@

# Table 11
CCITTFax_filter_entries.html :
	$(call table_to_html,38) > $@

# Table 12
JBIG2_filter_entries.html :
	$(call table_to_html,40) > $@

# Table 13
DCT_filter_entries.html :
	$(call table_to_html,43) > $@

# Table 14
Crypt_filter_entries.html :
	$(call table_to_html,46) > $@

# Table 15
File_trailer_entries.html :
	$(call table_to_html,51) > $@

# Table 16
Object_stream_entries.html :
	$(call table_to_html,54) > $@

# Table 17
Cross_reference_stream_entries.html :
	$(call table_to_html,58) > $@

# Table 18
Cross_reference_stream_fields.html :
	$(call table_to_html,59,--select=1) > $@

# Table 19
Hybrid-reference_entries.html :
	$(call table_to_html,59,--select=2) > $@

# Table 20
Encryption_common_entries.html :
	$(call table_to_html,64) > $@

# Table 21
Additional_encryption_entries.html :
	$(call table_to_html,68) > $@

# Table 22
User_access_permissions.html :
	$(call table_to_html,69) > $@

# Table 23
Public_key_security_handler_additional_entries.html :
	$(call table_to_html,73,--select=1) > $@

# Table 24
Public_key_security_handler_user_access_permissions.html :
	$(call table_to_html,73,--select=2) > $@

# Table 25
Crypt_filter_common_entries.html :
	$(call table_to_html,76) > $@

# Table 26
Standard_crypt_filter_names.html :
	$(call table_to_html,77,--select=1) > $@

# Table 27
Crypt_filter_public-key_additional_entries.html :
	$(call table_to_html,77,--select=2) > $@

# Table 28
Catalog_entries.html :
	$(call table_to_html,81) > $@

# Table 29
Pages_entries.html :
	$(call table_to_html,84) > $@

# Table 30
Page_entries.html :
	$(call table_to_html,85) > $@

# Table 31
Catalog_Name_tree_entries.html :
	$(call table_to_html,89) > $@

# Table 32
Compatibility_operators.html :
	$(call table_to_html,90) > $@

# Table 33
Resource_entries.html :
	$(call table_to_html,91) > $@

# Table 34
PDF_data_types.html :
	$(call table_to_html,92) > $@

# Table 35
String_object_data_types.html :
	$(call table_to_html,94) > $@

# Table 36
Name_tree_node_entries.html :
	$(call table_to_html,97) > $@

# Table 37
Number_tree_node_entries.html :
	$(call table_to_html,99) > $@

# Table 38
Function_common_entries.html :
	$(call table_to_html,101) > $@

# Table 39
Type_0_Function_entries.html :
	$(call table_to_html,102) > $@

# Table 40
Type_2_Function_entries.html :
	$(call table_to_html,104) > $@

# Table 41
Type_3_Function_entries.html :
	$(call table_to_html,105) > $@

# Table 42
Type_4_Function_operators.html :
	$(call table_to_html,106) > $@

# Table 43
File_specification_examples.html :
	$(call table_to_html,109) > $@

# Table 44
File_specification_entries.html :
	$(call table_to_html,110) > $@

# Table 45
Embedded_file_stream_entries.html :
	$(call table_to_html,112,--select=1) > $@

# Table 46
Embedded_file_parameter_entries.html :
	$(call table_to_html,112,--select=2) > $@

# Table 47
MacOS_file_information_entries.html :
	$(call table_to_html,113) > $@

# Table 48
Collection_item_entries.html :
	$(call table_to_html,114) > $@

# Table 49
Collection_subitem_entries.html :
	$(call table_to_html,115) > $@

# Table 50
Developer_extensions_entries.html :
	$(call table_to_html,116) > $@

# Table 51
Operator_categories.html :
	$(call table_to_html,120) > $@

# Table 52
Device_independent_graphics_state.html :
	$(call table_to_html,129) > $@

# Table 53
Device_dependent_graphics_state.html :
	$(call table_to_html,131) > $@

# Table 54
Line_cap_styles.html :
	$(call table_to_html,133,--select=1) > $@

# Table 55
Line_join_styles.html :
	$(call table_to_html,133,--select=2) > $@

# Table 56
Line_dash_examples.html :
	$(call table_to_html,135,--select=1) > $@

# Table 57
Graphics_state_operators.html :
	$(call table_to_html,135,--select=2) > $@

# Table 58
Graphics_state_entries.html :
	$(call table_to_html,136) > $@

# Table 59
Path_construction_operators.html :
	$(call table_to_html,140) > $@

# Table 60
Path_painting_operators.html :
	$(call table_to_html,143) > $@

# Table 61
Clipping_path_operators.html :
	$(call table_to_html,146) > $@

# Table 62
Colour_space_families.html :
	$(call table_to_html,147) > $@

# Table 63
CalGray_colour_space_entries.html :
	$(call table_to_html,153) > $@

# Table 64
CalRGB_colour_space_entries.html :
	$(call table_to_html,154) > $@

# Table 65
Lab_colour_space_entries.html :
	$(call table_to_html,156) > $@

# Table 66
ICC_profile_entries.html :
	$(call table_to_html,157) > $@

# Table 67
ICC_profile_versions.html :
	$(call table_to_html,158) > $@

# Table 68
ICC_profile_types.html :
	$(call table_to_html,159,--select=1) > $@

# Table 69
ICC_profile_ranges.html :
	$(call table_to_html,159,--select=2) > $@

# Table 70
Rendering_intents.html :
	$(call table_to_html,163) > $@

# Table 71
DeviceN_colour_space_attributes.html :
	$(call table_to_html,169) > $@

# Table 72
DeviceN_process_entries.html :
	$(call table_to_html,171,--select=1) > $@

# Table 73
DeviceN_mixing_hints_entries.html :
	$(call table_to_html,171,--select=2) > $@

# Table 74
Colour_operators.html :
	$(call table_to_html,179) > $@

# Table 75
Type_1_Pattern_entries.html :
	$(call table_to_html,182) > $@

# Table 76
Type_2_Pattern_entries.html :
	$(call table_to_html,189) > $@

# Table 77
Shading_operator.html :
	$(call table_to_html,190) > $@

# Table 78
Shading_common_entries.html :
	$(call table_to_html,191) > $@

# Table 79
Type_1_Shading_entries.html :
	$(call table_to_html,193) > $@

# Table 80
Type_2_Shading_entries.html :
	$(call table_to_html,194) > $@

# Table 81
Type_3_Shading_entries.html :
	$(call table_to_html,195) > $@

# Table 82
Type_4_Shading_entries.html :
	$(call table_to_html,197) > $@

# Table 83
Type_5_Shading_entries.html :
	$(call table_to_html,201) > $@

# Table 84
Type_6_Shading_entries.html :
	$(call table_to_html,204) > $@

# Table 85
Data_values_in_a_coons_patch_mesh.html :
	$(call table_to_html,206) > $@

# Table 86
Data_values_in_a_tensor_product_patch_mesh.html :
	$(call table_to_html,209) > $@

# Table 87
XObject_operator.html :
	$(call table_to_html,210,--select=1) > $@

# Table 88
Postscript_XObject_entries.html :
	$(call table_to_html,210,--select=2) > $@

# Table 89
Image_entries.html :
	$(call table_to_html,214) > $@

# Table 90
Default_decode_arrays.html :
	$(call table_to_html,218) > $@

# Table 91
Alternate_Image_entries.html :
	$(call table_to_html,220) > $@

# Table 92
Inline_Image_operators.html :
	$(call table_to_html,223,--select=1) > $@

# Table 93
Inline_Image_entries.html :
	$(call table_to_html,223,--select=2) > $@

# Table 94
Inline_Image_additional_operators.html :
	$(call table_to_html,223,--select=3) > $@

# Table 95
Type_1_Form_entries.html :
	$(call table_to_html,226) > $@

# Table 96
Group_Attributes_common_entries.html :
	$(call table_to_html,228) > $@

# Table 97
Reference_entries.html :
	$(call table_to_html,229) > $@

# Table 98
Optional_Content_Group_entries.html :
	$(call table_to_html,230) > $@

# Table 99
Optional_Content_Group_Membership_entries.html :
	$(call table_to_html,231) > $@

# Table 100
Optional_Content_Group_Properties_entries.html :
	$(call table_to_html,236) > $@

# Table 101
Optional_Content_Configuration_entries.html :
	$(call table_to_html,237) > $@

# Table 102
Optional_Content_Group_Usage_entries.html :
	$(call table_to_html,240) > $@

# Table 103
Optional_Content_Group_Application_entries.html :
	$(call table_to_html,241) > $@

# Table 104
Text_state_parameters.html :
	$(call table_to_html,251,--select=1) > $@

# Table 105
Text_state_operators.html :
	$(call table_to_html,251,--select=2) > $@

# Table 106
Text_rendering_modes.html :
	$(call table_to_html,255) > $@

# Table 107
Text_object_operators.html :
	$(call table_to_html,256) > $@

# Table 108
Text_position_operators.html :
	$(call table_to_html,257) > $@

# Table 109
Text_showing_operators.html :
	$(call table_to_html,258) > $@

# Table 110
Font_types.html :
	$(call table_to_html,261) > $@

# Table 111
Type_1_Font_entries.html :
	$(call table_to_html,262) > $@

# Table 112
Type_3_Font_entries.html :
	$(call table_to_html,266) > $@

# Table 113
Type_3_Font_operators.html :
	$(call table_to_html,268) > $@

# Table 114
Encoding_entries.html :
	$(call table_to_html,271) > $@

# Table 115
MacOS_encoding_differences.html :
	$(call table_to_html,274) > $@

# Table 116
CIDSystemInfo_entries.html :
	$(call table_to_html,276) > $@

# Table 117
CIDFont_entries.html :
	$(call table_to_html,277) > $@

# Table 118
CJK_CMap_names.html :
	$(call table_to_html,281) > $@

# Table 119
Character_collections_for_CMaps.html :
	$(call table_to_html,283) > $@

# Table 120
CMap_stream_entries.html :
	$(call table_to_html,285) > $@

# Table 121
Type_0_Font_entries.html :
	$(call table_to_html,287) > $@

# Table 122
Font_descriptor_common_entries.html :
	$(call table_to_html,290) > $@

# Table 123
Font_descriptor_flags.html :
	$(call table_to_html,291) > $@

# Table 124
CIDFont_descriptor_additional_entries.html :
	$(call table_to_html,293) > $@

# Table 125
Glyph_classes_in_CJK_fonts.html :
	$(call table_to_html,295) > $@

# Table 126
Embedded_font_organisation.html :
	$(call table_to_html,297) > $@

# Table 127
Embedded_font_stream_additional_entries.html :
	$(call table_to_html,298) > $@

# Table 128
Predefined_spot_functions.html :
	$(call table_to_html,311) > $@

# Table 129
Halftone_types.html :
	$(call table_to_html,316) > $@

# Table 130
Type_1_halftone_entries.html :
	$(call table_to_html,317) > $@

# Table 131
Type_6_halftone_entries.html :
	$(call table_to_html,318) > $@

# Table 132
Type_10_halftone_entries.html :
	$(call table_to_html,321) > $@

# Table 133
Type_16_halftone_entries.html :
	$(call table_to_html,322) > $@

# Table 134
Type_5_halftone_entries.html :
	$(call table_to_html,323) > $@

# Table 135
Basic_compositing_variables.html :
	$(call table_to_html,330) > $@

# Table 136
Standard_separable_blend_modes.html :
	$(call table_to_html,332) > $@

# Table 137
Standard_nonseparable_blend_modes.html :
	$(call table_to_html,335) > $@

# Table 138
Source_shape_and_opacity_formula_variables.html :
	$(call table_to_html,338) > $@

# Table 139
Result_shape_and_opacity_formula_variables.html :
	$(call table_to_html,339) > $@

# Table 140
Revised_basic_compositing_formula_variables.html :
	$(call table_to_html,341) > $@

# Table 141
Arguments_and_results_of_group_compositing_function.html :
	$(call table_to_html,343) > $@

# Table 142
Variables_used_in_the_group_compositing_formulas.html :
	$(call table_to_html,344) > $@

# Table 143
Variables_used_in_the_page_group_compositing_formulas.html :
	$(call table_to_html,348) > $@


# Table 144
Soft-mask_entries.html :
	$(call table_to_html,355) > $@

# Table 145
Soft-mask_image_restrictions.html :
	$(call table_to_html,356) > $@

# Table 146
Soft-mask_image_additional_entries.html :
	$(call table_to_html,357) > $@

# Table 147
Transparency_group_additional_entries.html :
	$(call table_to_html,358) > $@

# Table 148
Overprinting_behavior_in_the_opaque_imaging_model.html :
	$(call table_to_html,366) > $@

# Table 149
Overprinting_behavior_in_the_transparent_imaging_model.html :
	$(call table_to_html,367) > $@

# Table 150
Viewer_preferences_entries.html :
	$(call table_to_html,370) > $@

# Table 151
Destination_syntax.html :
	$(call table_to_html,374) > $@

# Table 152
Outline_entries.html :
	$(call table_to_html,376,--select=1) > $@

# Table 153
Outline_item_entries.html :
	$(call table_to_html,376,--select=2) > $@

# Table 154
Outline_item_flags.html :
	$(call table_to_html,377) > $@

# Table 155
Collection_entries.html :
	$(call table_to_html,379,--select=1) > $@

# Table 156
Collection_schema_entries.html :
	$(call table_to_html,379,--select=2) > $@

# Table 157
Collection_field_entries.html :
	$(call table_to_html,380) > $@

# Table 158
Collection_sort_entries.html :
	$(call table_to_html,381) > $@

# Table 159
Page_label_entries.html :
	$(call table_to_html,383) > $@

# Table 160
Thread_entries.html :
	$(call table_to_html,384,--select=1) > $@

# Table 161
Bead_entries.html :
	$(call table_to_html,384,--select=2) > $@

# Table 162
Transition_entries.html :
	$(call table_to_html,387) > $@

# Table 163
Navigation_node_entries.html :
	$(call table_to_html,388) > $@

# Table 164
Annotation_common_entries.html :
	$(call table_to_html,391) > $@

# Table 165
Annotation_flags.html :
	$(call table_to_html,393) > $@

# Table 166
Border_style_entries.html :
	$(call table_to_html,394) > $@

# Table 167
Border_effect_entries.html :
	$(call table_to_html,395) > $@

# Table 168
Appearance_entries.html :
	$(call table_to_html,397) > $@

# Table 169
Annotation_types.html :
	$(call table_to_html,398) > $@

# Table 170
Annotation_markup_additional_entries.html :
	$(call table_to_html,399) > $@

# Table 171
Annotation_states.html :
	$(call table_to_html,401) > $@

# Table 172
Text_annotation_additional_entries.html :
	$(call table_to_html,402,--select=1) > $@

# Table 173
Link_annotation_additional_entries.html :
	$(call table_to_html,402,--select=2) > $@

# Table 174
Free_text_annotation_additional_entries.html :
	$(call table_to_html,405) > $@

# Table 175
Line_annotation_additional_entries.html :
	$(call table_to_html,406) > $@

# Table 176
Line_ending_styles.html :
	$(call table_to_html,408) > $@

# Table 177
Square_or_circle_annotation_additional_entries.html :
	$(call table_to_html,409) > $@

# Table 178
Polygon_or_polyline_annotation_additional_entries.html :
	$(call table_to_html,410) > $@

# Table 179
Text_markup_annotation_additional_entries.html :
	$(call table_to_html,411) > $@

# Table 180
Caret_annotation_additional_entries.html :
	$(call table_to_html,412) > $@

# Table 181
Rubber_stamp_annotation_additional_entries.html :
	$(call table_to_html,413,--select=1) > $@

# Table 182
Ink_annotation_additional_entries.html :
	$(call table_to_html,413,--select=2) > $@

# Table 183
Popup_annotation_additional_entries.html :
	$(call table_to_html,414,--select=1) > $@

# Table 184
File_attachment_annotation_additional_entries.html :
	$(call table_to_html,414,--select=2) > $@

# Table 185
Sound_annotation_additional_entries.html :
	$(call table_to_html,415,--select=1) > $@

# Table 186
Movie_annotation_additional_entries.html :
	$(call table_to_html,415,--select=2) > $@

# Table 187
Screen_annotation_additional_entries.html :
	$(call table_to_html,415,--select=3) > $@

# Table 188
Widget_annotation_additional_entries.html :
	$(call table_to_html,416) > $@

# Table 189
Appearance_characteristics_entries.html :
	$(call table_to_html,417) > $@

# Table 190
Watermark_annotation_additional_entries.html :
	$(call table_to_html,419,--select=1) > $@

# Table 191
Fixed_print_entries.html :
	$(call table_to_html,419,--select=2) > $@

# Table 192
Redaction_annotation_additional_entries.html :
	$(call table_to_html,421) > $@

# Table 193
Action_common_entries.html :
	$(call table_to_html,422) > $@

# Table 194
Annotation_additional_actions_entries.html :
	$(call table_to_html,423) > $@

# Table 195
Page_additional_actions_entries.html :
	$(call table_to_html,424,--select=1) > $@

# Table 196
Form_additional_actions_entries.html :
	$(call table_to_html,424,--select=2) > $@

# Table 197
Catalog_additional_actions_entries.html :
	$(call table_to_html,425,--select=1) > $@

# Table 198
Action_types.html :
	$(call table_to_html,425,--select=2) > $@

# Table 199
Goto_action_additional_entries.html :
	$(call table_to_html,426) > $@

# Table 200
Remote_goto_action_additional_entries.html :
	$(call table_to_html,427) > $@

# Table 201
Embedded_goto_action_additional_entries.html :
	$(call table_to_html,428,--select=1) > $@

# Table 202
Target_entries.html :
	$(call table_to_html,428,--select=2) > $@

# Table 203
Launch_action_additional_entries.html :
	$(call table_to_html,430,--select=1) > $@

# Table 204
Windows_launch_parameters_entries.html :
	$(call table_to_html,430,--select=2) > $@

# Table 205
Thread_action_additional_entries.html :
	$(call table_to_html,431) > $@

# Table 206
URI_action_additional_entries.html :
	$(call table_to_html,432,--select=1) > $@

# Table 207
URI_entries.html :
	$(call table_to_html,432,--select=2) > $@

# Table 208
Sound_action_additional_entries.html :
	$(call table_to_html,433,--select=1) > $@

# Table 209
Movie_action_additional_entries.html :
	$(call table_to_html,433,--select=2) > $@

# Table 210
Hide_action_additional_entries.html :
	$(call table_to_html,434,--select=1) > $@

# Table 211
Named_actions.html :
	$(call table_to_html,434,--select=2) > $@

# Table 212
Named_action_additional_entries.html :
	$(call table_to_html,435,--select=1) > $@

# Table 213
Set-OCG-state_action_additional_entries.html :
	$(call table_to_html,435,--select=2) > $@

# Table 214
Rendition_action_additional_entries.html :
	$(call table_to_html,436) > $@

# Table 215
Transition_action_additional_entries.html :
	$(call table_to_html,437,--select=1) > $@

# Table 216
Goto_3D_view_action_additional_entries.html :
	$(call table_to_html,437,--select=2) > $@

# Table 217
JavaScript_action_additional_entries.html :
	$(call table_to_html,438) > $@

# Table 218
Interactive_form_entries.html :
	$(call table_to_html,439) > $@

# Table 219
Signature_flags.html :
	$(call table_to_html,440,--select=1) > $@

# Table 220
Field_common_entries.html :
	$(call table_to_html,440,--select=2) > $@

# Table 221
Field_flags.html :
	$(call table_to_html,441) > $@

# Table 222
Variable_text_field_entries.html :
	$(call table_to_html,442) > $@

# Table 223
XHTML_rich_text_string_elements.html :
	$(call table_to_html,444,--select=1) > $@

# Table 224
Body_element.html :
	$(call table_to_html,444,--select=2) > $@

# Table 225
CSS2_style_attributes.html :
	$(call table_to_html,445) > $@

# Table 226
Button_field_flags.html :
	$(call table_to_html,447) > $@

# Table 227
Check_box_and_radio_button_additional_entries.html :
	$(call table_to_html,449) > $@

# Table 228
Text_field_flags.html :
	$(call table_to_html,451) > $@

# Table 229
Text_field_additional_entries.html :
	$(call table_to_html,452,--select=1) > $@

# Table 230
Choice_field_flags.html :
	$(call table_to_html,452,--select=2) > $@

# Table 231
Choice_field_additional_entries.html :
	$(call table_to_html,453) > $@

# Table 232
Signature_field_entries.html :
	$(call table_to_html,454) > $@

# Table 233
Signature_field_lock_entries.html :
	$(call table_to_html,455,--select=1) > $@

# Table 234
Signature_field_seed_value_entries.html :
	$(call table_to_html,455,--select=2) > $@

# Table 235
Certificate_seed_value_entries.html :
	$(call table_to_html,457) > $@

# Table 236
Submit_form_action_entries.html :
	$(call table_to_html,459) > $@

# Table 237
Submit_form_action_flags.html :
	$(call table_to_html,460) > $@

# Table 238
Reset_form_action_entries.html :
	$(call table_to_html,463,--select=1) > $@

# Table 239
Reset_form_action_flags.html :
	$(call table_to_html,463,--select=2) > $@

# Table 240
Import-data_action_additional_entries.html :
	$(call table_to_html,464) > $@

# Table 241
FDF_trailer_entries.html :
	$(call table_to_html,466,--select=1) > $@

# Table 242
FDF_catalog_entries.html :
	$(call table_to_html,466,--select=2) > $@

# Table 243
FDF_dictionary_entries.html :
	$(call table_to_html,467) > $@

# Table 244
Embedded_file_stream_entries_FDF_additional.html :
	$(call table_to_html,468) > $@

# Table 245
JavaScript_entries.html :
	$(call table_to_html,469,--select=1) > $@

# Table 246
FDF_field_entries.html :
	$(call table_to_html,469,--select=2) > $@

# Table 247
Icon_fit_entries.html :
	$(call table_to_html,471,--select=1) > $@

# Table 248
FDF_page_entries.html :
	$(call table_to_html,471,--select=2) > $@

# Table 249
FDF_template_entries.html :
	$(call table_to_html,472,--select=1) > $@

# Table 250
FDF_named_page_reference_entries.html :
	$(call table_to_html,472,--select=2) > $@

# Table 251
FDF_annotation_additional_entries.html :
	$(call table_to_html,472,--select=3) > $@

# Table 252
Signature_entries.html :
	$(call table_to_html,475) > $@

# Table 253
Signature_reference_entries.html :
	$(call table_to_html,477) > $@

# Table 254
DocMDP_transform_entries.html :
	$(call table_to_html,479) > $@

# Table 255
UR_transform_entries.html :
	$(call table_to_html,480) > $@

# Table 256
FieldMDP_transform_entries.html :
	$(call table_to_html,481) > $@

# Table 257
SubFilter_value_algorithm_support.html :
	$(call table_to_html,484) > $@

# Table 258
Permissions_entries.html :
	$(call table_to_html,485) > $@

# Table 259
Legal_attestation_entries.html :
	$(call table_to_html,486) > $@

# Table 260
Viewport_entries.html :
	$(call table_to_html,487) > $@

# Table 261
Measure_entries.html :
	$(call table_to_html,488) > $@

# Table 262
Rectilinear_measure_additional_entries.html :
	$(call table_to_html,489) > $@

# Table 263
Number_format_entries.html :
	$(call table_to_html,490) > $@

# Table 264
Requirement_common_entries.html :
	$(call table_to_html,492) > $@

# Table 265
Requirement_handler_entries.html :
	$(call table_to_html,493) > $@

# Table 266
Rendition_common_entries.html :
	$(call table_to_html,497,--select=1) > $@

# Table 267
Rendition_MH-BE_entries.html :
	$(call table_to_html,497,--select=2) > $@

# Table 268
Rendition_criteria_entries.html :
	$(call table_to_html,497,--select=3) > $@

# Table 269
Minimum_bit_depth_entries.html :
	$(call table_to_html,498) > $@

# Table 270
Minimum_screen_size_entries.html :
	$(call table_to_html,499,--select=1) > $@

# Table 271
Media_rendition_entries.html :
	$(call table_to_html,499,--select=2) > $@

# Table 272
Selector_rendition_entries.html :
	$(call table_to_html,500,--select=1) > $@

# Table 273
Media_clip_common_entries.html :
	$(call table_to_html,500,--select=2) > $@

# Table 274
Media_clip_data_entries.html :
	$(call table_to_html,500,--select=3) > $@

# Table 275
Media_permissions_entries.html :
	$(call table_to_html,502,--select=1) > $@

# Table 276
Media_clip_data_MH-BE_entries.html :
	$(call table_to_html,502,--select=2) > $@

# Table 277
Media_clip_section_entries.html :
	$(call table_to_html,503) > $@

# Table 278
Media_clip_section_MH-BE_entries.html :
	$(call table_to_html,504,--select=1) > $@

# Table 279
Media_play_parameters_entries.html :
	$(call table_to_html,504,--select=2) > $@

# Table 280
Media_play_parameters_MH-BE-entries.html :
	$(call table_to_html,504,--select=3) > $@

# Table 281
Media_duration_entries.html :
	$(call table_to_html,506,--select=1) > $@

# Table 282
Media_screen_parameters_entries.html :
	$(call table_to_html,506,--select=2) > $@

# Table 283
Media_screen_parameters_MH-BE_entries.html :
	$(call table_to_html,507) > $@

# Table 284
Floating_window_parameter_entries.html :
	$(call table_to_html,508) > $@

# Table 285
Media_offset_common_entries.html :
	$(call table_to_html,509,--select=1) > $@

# Table 286
Media_offset_time_entries.html :
	$(call table_to_html,509,--select=2) > $@

# Table 287
Media_offset_frame_entries.html :
	$(call table_to_html,509,--select=3) > $@

# Table 288
Media_offset_marker_entries.html :
	$(call table_to_html,509,--select=4) > $@

# Table 289
Timespan_entries.html :
	$(call table_to_html,510,--select=1) > $@

# Table 290
Media_players_entries.html :
	$(call table_to_html,510,--select=2) > $@

# Table 291
Media_player_info_entries.html :
	$(call table_to_html,511) > $@

# Table 292
Software_identifier_entries.html :
	$(call table_to_html,512) > $@

# Table 293
Monitor_specifier_values.html :
	$(call table_to_html,514,--select=1) > $@

# Table 294
Sound_object_entries.html :
	$(call table_to_html,514,--select=2) > $@

# Table 295
Movie_entries.html :
	$(call table_to_html,516,--select=1) > $@

# Table 296
Movie_activation_entries.html :
	$(call table_to_html,516,--select=2) > $@

# Table 297
Slideshow_entries.html :
	$(call table_to_html,518) > $@

# Table 298
Three-D_annotation_entries.html :
	$(call table_to_html,520) > $@


# Table 299
Three-D_activation_entries.html :
	$(call table_to_html,522) > $@

# Table 300
Three-D_stream_entries.html :
	$(call table_to_html,524) > $@

# Table 301
Three-D_animation_style_entries.html :
	$(call table_to_html,525) > $@

# Table 302
Animation_styles.html :
	$(call table_to_html,526) > $@

# Table 303
Three-D_reference_entries.html :
	$(call table_to_html,527) > $@

# Table 304
Three-D_view_entries.html :
	$(call table_to_html,529) > $@

# Table 305
Projection_entries.html :
	$(call table_to_html,532) > $@

# Table 306
Three-D_background_entries.html :
	$(call table_to_html,535,--select=1) > $@

# Table 307
Render_mode_entries.html :
	$(call table_to_html,535,--select=2) > $@

# Table 308
Render_modes.html :
	$(call table_to_html,537) > $@

# Table 309
Three-D_lighting_entries.html :
	$(call table_to_html,538,--select=1) > $@

# Table 310
Three-D_lighting_styles.html :
	$(call table_to_html,538,--select=2) > $@

# Table 311
Three-D_cross_section_entries.html :
	$(call table_to_html,540) > $@

# Table 312
Three-D_node_entries.html :
	$(call table_to_html,546) > $@

# Table 313
Three-D_external_data_entries.html :
	$(call table_to_html,551) > $@

# Table 314
Predefined_procedure_set.html :
	$(call table_to_html,555) > $@

# Table 315
Metadata_stream_additional_entries.html :
	$(call table_to_html,557,--select=1) > $@

# Table 316
Metadata_additional_entries.html :
	$(call table_to_html,557,--select=2) > $@

# Table 317
Info_entries.html :
	$(call table_to_html,558) > $@

# Table 318
Page-piece_entries.html :
	$(call table_to_html,560,--select=1) > $@

# Table 319
Data_entries.html :
	$(call table_to_html,560,--select=2) > $@

# Table 320
Marked_content_operators.html :
	$(call table_to_html,561) > $@

# Table 321
Mark_information_entries.html :
	$(call table_to_html,564) > $@

# Table 322
Structure_tree_root_entries.html :
	$(call table_to_html,565) > $@

# Table 323
Structure_tree_element_entries.html :
	$(call table_to_html,566) > $@

# Table 324
Marked_content_reference_entries.html :
	$(call table_to_html,569) > $@

# Table 325
Object_reference_entries.html :
	$(call table_to_html,572) > $@

# Table 326
Structure_element_access_additional_entries.html :
	$(call table_to_html,573) > $@

# Table 327
Attribute_object_entries.html :
	$(call table_to_html,575) > $@

# Table 328
Attribute_object_for_user_properties_entries.html :
	$(call table_to_html,577,--select=1) > $@

# Table 329
User_property_entries.html :
	$(call table_to_html,577,--select=2) > $@

# Table 330
Artifact_entries.html :
	$(call table_to_html,583) > $@

# Table 331
Font_characteristic_derivation.html :
	$(call table_to_html,588,--select=1) > $@

# Table 332
Font_selector_attributes.html :
	$(call table_to_html,588,--select=2) > $@

# Table 333
Standard_structure_types_for_grouping_elements.html :
	$(call table_to_html,591) > $@

# Table 334
Block_level_structure_elements.html :
	$(call table_to_html,593,--select=1) > $@

# Table 335
Standard_structure_types_for_paragraphlike_elements.html :
	$(call table_to_html,593,--select=2) > $@

# Table 336
Standard_structure_types_for_list_elements.html :
	$(call table_to_html,593,--select=3) > $@

# Table 337
Standard_structure_types_for_table_elements.html :
	$(call table_to_html,594) > $@

# Table 338
Standard_structure_types_for_inline-level_elements.html :
	$(call table_to_html,596) > $@


# Table 339
Standard_structure_types_for_Ruby_and_Warichu_elements.html :
	$(call table_to_html,599) > $@

# Table 340
Standard_structure_types_for_illustration_elements.html :
	$(call table_to_html,600) > $@

# Table 341
Standard_attribute_owners.html :
	$(call table_to_html,601) > $@

# Table 342
Standard_layout.html :
	$(call table_to_html,603) > $@

# Table 343
Standard_layout_structure_type_attributes.html :
	$(call table_to_html,605) > $@

# Table 344
Standard_layout_block-level_structure_element_attributes.html :
	$(call table_to_html,608) > $@

# Table 345
Standard_inline-level_structure_element_attributes.html :
	$(call table_to_html,612) > $@

# Table 346
Standard_column_attributes.html :
	$(call table_to_html,616,--select=1) > $@

# Table 347
Standard_list_attributes.html :
	$(call table_to_html,616,--select=2) > $@

# Table 348
PrintField_attributes.html :
	$(call table_to_html,617) > $@

# Table 348
Standard_table_attributes.html :
	$(call table_to_html,618) > $@

# Table 350
Web_Capture_information_entries.html :
	$(call table_to_html,625) > $@

# Table 351
Characters_with_special_meanings.html :
	$(call table_to_html,629,--select=1) > $@

# Table 352
Web_Capture_content_sets_entries.html :
	$(call table_to_html,629,--select=2) > $@

# Table 353
Web_Capture_page_set_additional_entries.html :
	$(call table_to_html,630,--select=1) > $@

# Table 354
Web_Capture_image_set_entries.html :
	$(call table_to_html,630,--select=2) > $@

# Table 355
Source_information_entries.html :
	$(call table_to_html,631) > $@

# Table 356
URL_alias_entries.html :
	$(call table_to_html,632,--select=1) > $@

# Table 357
Web_capture_command_entries.html :
	$(call table_to_html,632,--select=2) > $@

# Table 358
Web_capture_command_flags.html :
	$(call table_to_html,633) > $@

# Table 359
Web_capture_command_settings_entries.html :
	$(call table_to_html,634) > $@

# Table 360
Box_colour_information_entries.html :
	$(call table_to_html,638) > $@

# Table 361
Box_style_entries.html :
	$(call table_to_html,639) > $@

# Table 362
Printers_mark_annotation_entries.html :
	$(call table_to_html,640,--select=1) > $@

# Table 363
Printers_mark_form_entries.html :
	$(call table_to_html,640,--select=2) > $@

# Table 364
Separation_entries.html :
	$(call table_to_html,640,--select=3) > $@

# Table 365
Output_intent_entries.html :
	$(call table_to_html,641) > $@

# Table 366
Trap_network_annotation_entries.html :
	$(call table_to_html,645) > $@

# Table 367
Trap_network_appearance_stream_entries.html :
	$(call table_to_html,646) > $@

# Table 368
OPI_version_entries.html :
	$(call table_to_html,647,--select=1) > $@

# Table 369
OPI_version_1_3_entries.html :
	$(call table_to_html,647,--select=2) > $@

# Table 369
OPI_version_2_0_entries.html :
	$(call table_to_html,649) > $@

#--- Appendix ---

# Table A.1
PDF_content_stream_operators.html :
	$(call table_to_html,651) > $@

# Table C.1
Architectural_limits.html :
	$(call table_to_html,657) > $@

# Table D.1
Latin-text_encodings.html :
	$(call table_to_html,659) > $@

# Table D.2
PDFDocEncoding_Character_Set.html :
	$(call table_to_html,664) > $@

# Table F.1
Linearization_parameter_entries.html :
	$(call table_to_html,688) > $@

# Table F.2
Standard_hint_tables.html :
	$(call table_to_html,690) > $@

# Table F.3
Page_offset_hint_tables-header_section.html :
	$(call table_to_html,695) > $@

# Table F.4
Page_offset_hint_tables-per_page_entry.html :
	$(call table_to_html,696) > $@

# Table F.5
Shared_object_hint_table-header_section.html :
	$(call table_to_html,698,--select=1) > $@

# Table F.6
Shared_object_hint_table-shared_object_group_entry.html :
	$(call table_to_html,698,--select=2) > $@

# Table F.7
Thumbnail_hint_table-header_section.html :
	$(call table_to_html,699) > $@

# Table F.8
Thumbnail_hint_table-per_page_entry.html :
	$(call table_to_html,700) > $@

# Table F.9
Generic_hint_table.html :
	$(call table_to_html,701,--select=1) > $@

# Table F.10
Extended_generic_hint_table.html :
	$(call table_to_html,701,--select=2) > $@

# Table F.11
Embedded_file_stream_hint_table-header_section.html :
	$(call table_to_html,702,--select=1) > $@

# Table F.12
Embedded_file_stream_hint_table-per_file_stream.html :
	$(call table_to_html,702,--select=2) > $@
