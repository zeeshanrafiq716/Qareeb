-- Migration 008: Expand document types and enforce compulsory documents
ALTER TABLE verifications DROP CONSTRAINT IF EXISTS verifications_document_type_check;

ALTER TABLE verifications ADD CONSTRAINT verifications_document_type_check
CHECK (document_type IN (
  'iqama',
  'registration',
  'license',
  'driving_licence',
  'vehicle_photos',
  'vehicle_front',
  'vehicle_rear',
  'vehicle_left_side',
  'vehicle_right_side',
  'cnic',
  'passport',
  'other'
));

