# Roles for PDF::Annot::ThreeD, PDF::ExData::Markup3D

use PDF::COS::Tie::Hash;

role PDF::Class::ThreeD
    does PDF::COS::Tie::Hash {

    use PDF::COS::Tie;
    use PDF::COS::Name;

    my subset DefaultViewName of PDF::COS::Name where 'F'|'L'|'D';
    my subset DefaultView where UInt|Str|DefaultViewName;
    has DefaultView $.default-view is entry(:key<3DV>);      # (Optional) An object that specifies the default initial view of the 3D artwork that shall be used when the annotation is activated. It may be either a 3D view dictionary or one of the following types:
    # • An integer specifying an index into the VA array.
    # • A text string matching the IN entry in one of the views in the VA array.
    # • A name that indicates the first (F), last (L), or default (D) entries in the VA array.

    my role Activation is PDF::COS::Tie::Hash {
        ## use ISO_32000::Three-D_activation;
        ## also does ISO_32000::Three-D_activation;
        my subset ActiviationCircumstances of PDF::COS::Name where 'PO'|'PV'|'XA';
        has $.A is entry(:alias<activation>);	# [name] (Optional) A name specifying the circumstances under which the annotation is activated. Valid values are:
            # PO The annotation is activated as soon as the page containing the annotation is opened.
            # PV The annotation is activated as soon as any part of the page containing the annotation becomes visible.
            # XA The annotation shall remain inactive until explicitly activated by a script or user action.
            # NOTE 1 At any one time, only a single page is considered open in a conforming reader, even though more than one page may be visible, depending on the page layout. Default value: XA.
            # NOTE 2 For performance reasons, documents intended for viewing in a web browser should use explicit activation (XA). In non-interactive applications, such as printing systems or aggregating conforming reader, PO and PV indicate that the annotation is activated when the page is printed or placed; XA indicates that the annotation shall never be activated and the normal appearance is used.
        my subset ActivationState of PDF::COS::Name where 'IT'|'L';
        has ActivationState $.AIS is entry(:alias<artwork-state>);	# [name] (Optional) A name specifying the state of the artwork instance upon activation of the annotation. Valid values are:
            # IThe artwork is instantiated, but real-time script-driven animations is disabled.
            # L Real-time script-driven animations is enabled if present; if not, the artwork is instantiated.
            # Default value: L.
            # NOTE 3 In non-interactive conforming readers, the artwork is instantiated and scripts is disabled.
        my subset DeactiviationCircumstances of PDF::COS::Name where 'PC'|'PI'|'XD';
        has DeactiviationCircumstances $.D is entry(:alias<deactivation>);	# [name] (Optional) A name specifying the circumstances under which the annotation is deactivated. Valid values are:
            # PC The annotation is deactivated as soon as the page is closed.
            # PI The annotation is deactivated as soon as the page containing the annotation becomes invisible.
            # XD The annotation shall remain active until explicitly deactivated by a script or user action.
            # NOTE 4 At any one time, only a single page is considered open in the conforming reader, even though more than one page may be visible, depending on the page layout. Default value: PI.
        my subset DeactivationState of PDF::COS::Name where 'U'|'I'|'L';
        has $.DIS is entry(:alias<deactivitation-state>);	# [name] (Optional) A name specifying the state of the artwork instance upon deactivation of the annotation. Valid values are U (uninstantiated), I(instantiated), and L (live). Default value: U.
            # NOTE 5 If the value of this entry is L, uninstantiation of instantiated artwork is necessary unless it has been modified. Uninstantiation is never required in non-interactive conforming readers.
        has Bool $.TB is entry(:alias<tool-bar-display>);	# [boolean] (Optional; PDF 1.7) A flag indicating the default behavior of an interactive toolbar associated with this annotation. If true, a toolbar is displayed by default when the annotation is activated and given focus. If false, a toolbar shall not be displayed by default.
            # NOTE 6 Typically, a toolbar is positioned in proximity to the 3D annotation. Default value: true.
        has Bool $.NP is entry(:alias<ui-display>, :!default);	# [boolean] (Optional; PDF 1.7) A flag indicating the default behavior of the user interface for viewing or managing information about the 3D artwork. Such user interfaces can enable navigation to different views or can depict the hierarchy of the objects in the artwork (the model tree). If true, the user interface should be made visible when the annotation is activated. If false, the user interface should not be made visible by default.
            # Default value: false
    }

    has Activation $.activation is entry(:key<3DA>);   # dictionary (Optional) An activation dictionary that defines the times at which the annotation shall be activated and deactivated and the state of the 3D artwork instance at those times.
}
