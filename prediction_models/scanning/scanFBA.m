%% Scans the FBA dataset, returning metadata about student auditions.
% CL@GTCMT 2015
% Metadata is returned in the form of a struct, audition_metadata, which is
% described below.
%
%                         %%%% Input %%%%
% fba_relative_path: string, the relative path from the /predictive_models
%                    directory to the FBA2013 directory containing audio
%                    files in your computer's file system.
% band_option:       string specifying the band: 'middle', 'concert'
%                    or 'symphonic'
% instrument_option: string specifying instrument as it appears in the xls
% segment_option: N*1 int vector, specify your target segments, ex: [3; 5]
%
%                         %%%% Output %%%%
% Fields of audition_metadata:
%   file_paths: string, the path to each audio file for a student.
%   segments: N*1 cell vector, each cell is a m*2 matrix,
%             1st column = starting time, 2nd column = duration.
%   assessments: N*1 cell vector, each cell is a F*G vector
%                N -> student_id's, F -> segment, G -> category (all 26).
%                For segment and category indices, see /FBA/README.txt.
%                Segments returned in order specified by segment_option.
%   score: TODO(Yujia)
%   pyin_path: string, the path to pyin pitch contour for a student
%
% file_paths, segments, and assessments have the same index for a given
% student.
function audition_metadata = scanFBA(fba_relative_path, band_option, ...
    instrument_option, segment_option, ...
    score_option, year_option)
root_path = deriveRootPath();
full_fba_relative_path = [root_path fba_relative_path];

% Figure out which students we retrive metadata for.
% student_ids is a N X 1 vector.
student_ids = scanStudentIds(band_option, instrument_option, year_option);
%student_ids = setdiff(student_ids, ids2skip);

% Scan audio filepaths
file_paths = scanFilePaths(full_fba_relative_path, student_ids, year_option);

% Scan annotations for segment informations
segments = scanSegments(segment_option, student_ids, year_option);
segment_option_remapped = segmentRemap(segment_option, instrument_option);

% Scan assessments
assessments = scanAssessments(segment_option_remapped, student_ids, year_option);

% Scan score
% TODO - Finish the scanScore method to return the path to the midi score
% score = scanScore(instrument_option, score_option);
score_path = ...
    scanScorePath(band_option, year_option, instrument_option, segment_option);
pyin_paths = scanPyinPaths(student_ids, band_option, year_option);

% Create the struct.
audition_metadata = struct();
audition_metadata.file_paths = file_paths;
audition_metadata.segments = segments;
audition_metadata.assessments = assessments;
audition_metadata.score_path = score_path;
audition_metadata.pyin_paths = pyin_paths;
audition_metadata.student_ids = student_ids;
end