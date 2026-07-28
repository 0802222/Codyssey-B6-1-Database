USE codyssey_mission_db;

-- 1) 학생 샘플 데이터 (10명 이상)
INSERT INTO student (name, email, track)
VALUES
('김백엔',  'kimbe_backend@example.com',   'AI SW Basic'),
('이프론',  'lee_frontend@example.com',    'AI SW Basic'),
('박데브',  'park_devops@example.com',     'AI SW Basic'),
('최데이터','choi_data@example.com',       'AI SW Basic'),
('정풀스',  'jung_fullstack@example.com',  'AI SW Advanced'),
('한AI',    'han_ai@example.com',          'AI SW Advanced'),
('오서버',  'oh_server@example.com',       'AI SW Advanced'),
('유웹',    'yoo_web@example.com',         'AI SW Master'),
('장코디',  'jang_codyssey@example.com',   'AI SW Basic'),
('신알고',  'shin_algo@example.com',       'AI SW Master');

-- 2) 미션 샘플 데이터 (10개 이상)
INSERT INTO mission (title, category, difficulty, estimated_hours)
VALUES
('B1-1 시스템 관제 자동화 스크립트 개발', 'SERVER_OPS',   '2', 40),
('B2-1 로그 분석 및 모니터링 대시보드',     'DATA', '2', 32),
('B3-1 Codyssey 미션 관리 DB 설계',        'BACKEND',   '2', 40),
('B4-1 REST API 설계와 인증',              'BACKEND',       '3', 48),
('A1-1 웹 기초와 HTML/CSS',                'WEB_BASIC',       '1', 16),
('A2-1 JavaScript 비동기 처리',            'FRONTEND',   '2', 24),
('A3-1 React 컴포넌트 설계',               'FRONTEND',   '3', 40),
('C1-1 AI 모델 서빙 기초',                 'AI_SERVING',      '3', 40),
('C2-1 SQL로 보는 데이터 분석',            'DATA',       '1', 24),
('C3-1 인덱스와 쿼리 튜닝',                 'BACKEND',   '3', 32);

-- 3) 진도 샘플 데이터
-- 가정: student.id = 1~10, mission.id = 1~10
-- attempt_no는 각 학생·미션별 첫 도전을 1로 둠
-- 3) 진도 샘플 데이터
INSERT INTO mission_progress
    (student_id, mission_id, attempt_no, status, reviewed_at, final_result)
VALUES
(1, 1, 1, 'DONE',        '2026-06-20 10:00:00', 'NOT_STARTED'),
(2, 1, 1, 'DONE',        '2026-06-20 11:00:00', 'NOT_STARTED'),
(3, 1, 1, 'IN_PROGRESS', NULL,                  'IN_PROGRESS'),
(4, 1, 1, 'NOT_STARTED', NULL,                  'NOT_STARTED'),
(1, 3, 1, 'DONE',        '2026-06-25 15:00:00', 'NOT_STARTED'),
(2, 3, 1, 'DONE',        '2026-06-25 16:00:00', 'NOT_STARTED'),
(3, 3, 1, 'IN_PROGRESS', NULL,                  'IN_PROGRESS'),
(5, 3, 1, 'DONE',        '2026-06-26 09:30:00', 'NOT_STARTED'),
(6, 9, 1, 'DONE',        '2026-06-19 13:00:00', 'PASS'),
(7, 9, 1, 'DONE',        '2026-06-19 14:00:00', 'FAIL'),
(8, 2, 1, 'IN_PROGRESS', NULL,                  'IN_PROGRESS'),
(9, 2, 1, 'NOT_STARTED', NULL,                  'NOT_STARTED'),
(10, 2, 1, 'IN_PROGRESS', NULL,                 'IN_PROGRESS'),
(4, 5, 1, 'DONE',        '2026-06-21 10:00:00', 'NOT_STARTED'),
(5, 5, 1, 'NOT_STARTED', NULL,                  'NOT_STARTED'),
(6, 6, 1, 'DONE',        '2026-06-22 10:00:00', 'NOT_STARTED'),
(7, 7, 1, 'IN_PROGRESS', NULL,                  'IN_PROGRESS'),
(8, 8, 1, 'NOT_STARTED', NULL,                  'NOT_STARTED'),
(9, 10, 1, 'DONE',       '2026-06-23 10:00:00', 'NOT_STARTED'),
(10, 10, 1, 'DONE',      '2026-06-23 11:00:00', 'NOT_STARTED');

-- 4) 동료평가 샘플 데이터
-- 규칙: mission_id + attempt_no + reviewer_student_id + reviewee_student_id 는 UNIQUE
-- 모든 예시는 첫 도전 attempt_no = 1 기준 평가라고 가정

INSERT INTO peer_review (mission_id, attempt_no, reviewer_student_id, reviewee_student_id, review_result, comment)
VALUES
(3, 1, 2, 1, 'PASS', '요구사항대로 테이블 잘 나눴음'),
(3, 1, 3, 1, 'PASS', 'FK/제약조건 설계가 자연스러움'),
(3, 1, 5, 1, 'PASS', '쿼리 15개가 실무 요구 잘 반영됨'),
(3, 1, 1, 2, 'PASS', '기본 스키마는 잘 설계됨'),
(3, 1, 3, 2, 'FAIL', '동료평가 로직 설명이 부족함'),
(3, 1, 5, 2, 'PASS', '쿼리 쪽은 괜찮음'),
(9, 1, 1, 6, 'PASS', '집계 쿼리가 잘 작성되어 있음'),
(9, 1, 2, 6, 'PASS', 'GROUP BY 활용 좋음'),
(9, 1, 3, 6, 'PASS', '인덱스 활용에 대한 이해가 드러남'),
(9, 1, 1, 7, 'FAIL', '샘플 데이터가 부족함'),
(9, 1, 2, 7, 'PASS', '기본 SELECT는 잘 됨'),
(1, 1, 2, 1, 'PASS', '로그 구조 설명이 좋음'),
(1, 1, 3, 2, 'PASS', 'cron 활용 이해가 좋음'),
(1, 1, 5, 3, 'FAIL', '방화벽 설정 설명이 부족함'),
(2, 1, 6, 8, 'PASS', '대시보드 UX가 좋음'),
(2, 1, 7, 9, 'PASS', '쿼리 최적화가 잘 되어 있음'),
(5, 1, 1, 4, 'PASS', 'HTML/CSS 마크업 구조 좋음');