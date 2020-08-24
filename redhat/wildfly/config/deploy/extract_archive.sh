function ExtractArchive {
    # Find the line inside this file, where the archive starts
    ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $0`
 
    # Grab the archive part, and extract it into the temp directory
    tail -n+${ARCHIVE} $0 > ${TMPDIR}/our_assembly.war
}
 
__ARCHIVE_BELOW__