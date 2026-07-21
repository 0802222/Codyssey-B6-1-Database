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
('B1-1 시스템 관제 자동화 스크립트 개발', '서버/운영',   '중급', 40),
('B2-1 로그 분석 및 모니터링 대시보드',     '데이터/로그', '중급', 32),
('B3-1 Codyssey 미션 관리 DB 설계',        'DB/백엔드',   '중급', 40),
('B4-1 REST API 설계와 인증',              '백엔드',       '고급', 48),
('A1-1 웹 기초와 HTML/CSS',                '웹기초',       '초급', 16),
('A2-1 JavaScript 비동기 처리',            '프론트엔드',   '중급', 24),
('A3-1 React 컴포넌트 설계',               '프론트엔드',   '고급', 40),
('C1-1 AI 모델 서빙 기초',                 'AI/서빙',      '고급', 40),
('C2-1 SQL로 보는 데이터 분석',            '데이터',       '초급', 24),
('C3-1 인덱스와 쿼리 튜닝',                 'DB/백엔드',   '고급', 32);

-- 3) 진도 샘플 데이터
-- 가정: student.id = 1~10, mission.id = 1~10
-- 일부는 아직 시작 안 함, 일부는 진행 중, 일부는 제출 완료(PENDING), 일부는 PASS/FAIL

INSERT INTO mission_progress (student_id, mission_id, status, submitted_at, final_result)
VALUES
-- B1-1: 1~4번 학생
(1, 1, 'DONE',        '2026-06-20 10:00:00', 'PENDING'),
(2, 1, 'DONE',        '2026-06-20 11:00:00', 'PENDING'),
(3, 1, 'IN_PROGRESS', NULL,                  'PENDING'),
(4, 1, 'NOT_STARTED', NULL,                  'PENDING'),

-- B3-1: Codyssey 미션 관리 DB 설계
(1, 3, 'DONE',        '2026-06-25 15:00:00', 'PENDING'),
(2, 3, 'SUBMITTED',   '2026-06-25 16:00:00', 'PENDING'),
(3, 3, 'IN_PROGRESS', NULL,                  'PENDING'),
(5, 3, 'DONE',        '2026-06-26 09:30:00', 'PENDING'),

-- C2-1: SQL로 보는 데이터 분석
(6, 9, 'DONE',        '2026-06-19 13:00:00', 'PASS'),
(7, 9, 'DONE',        '2026-06-19 14:00:00', 'FAIL');

-- 상태만 있는 추가 진도 (10행 이상 채우기)
INSERT INTO mission_progress (student_id, mission_id, status)
VALUES
(8, 2, 'IN_PROGRESS'),
(9, 2, 'NOT_STARTED'),
(10, 2, 'IN_PROGRESS'),
(4, 5, 'DONE'),
(5, 5, 'NOT_STARTED'),
(6, 6, 'DONE'),
(7, 7, 'IN_PROGRESS'),
(8, 8, 'NOT_STARTED'),
(9, 10, 'DONE'),
(10, 10, 'SUBMITTED');

-- 4) 동료평가 샘플 데이터
-- 규칙: mission_id + reviewer_student_id + reviewee_student_id 는 UNIQUE

-- 사례 1: student_id=1, mission_id=3 → 평가 3개 모두 PASS → 최종 PASS 될 케이스
INSERT INTO peer_review (mission_id, reviewer_student_id, reviewee_student_id, review_result, comment)
VALUES
(3, 2, 1, 'PASS', '요구사항대로 테이블 잘 나눴음'),
(3, 3, 1, 'PASS', 'FK/제약조건 설계가 자연스러움'),
(3, 5, 1, 'PASS', '쿼리 15개가 실무 요구 잘 반영됨');

-- 사례 2: student_id=2, mission_id=3 → 평가 3개 중 1개 FAIL → 최종 FAIL 케이스
INSERT INTO peer_review (mission_id, reviewer_student_id, reviewee_student_id, review_result, comment)
VALUES
(3, 1, 2, 'PASS', '기본 스키마는 잘 설계됨'),
(3, 3, 2, 'FAIL', '동료평가 로직 설명이 부족함'),
(3, 5, 2, 'PASS', '쿼리 쪽은 괜찮음');

-- 사례 3: student_id=6, mission_id=9 → 이미 최종 PASS된 미션, 동료평가 3개 PASS
INSERT INTO peer_review (mission_id, reviewer_student_id, reviewee_student_id, review_result, comment)
VALUES
(9, 1, 6, 'PASS', '집계 쿼리가 잘 작성되어 있음'),
(9, 2, 6, 'PASS', 'GROUP BY 활용 좋음'),
(9, 3, 6, 'PASS', '인덱스 활용에 대한 이해가 드러남');

-- 사례 4: student_id=7, mission_id=9 → 동료평가 2개만 있고 둘 중 하나 FAIL → 아직 PENDING 또는 FAIL
INSERT INTO peer_review (mission_id, reviewer_student_id, reviewee_student_id, review_result, comment)
VALUES
(9, 1, 7, 'FAIL', '샘플 데이터가 부족함'),
(9, 2, 7, 'PASS', '기본 SELECT는 잘 됨');

-- 추가 동료평가 (테이블 10행 이상)
INSERT INTO peer_review (mission_id, reviewer_student_id, reviewee_student_id, review_result, comment)
VALUES
(1, 2, 1, 'PASS', '로그 구조 설명이 좋음'),
(1, 3, 2, 'PASS', 'cron 활용 이해가 좋음'),
(1, 5, 3, 'FAIL', '방화벽 설정 설명이 부족함'),
(2, 6, 8, 'PASS', '대시보드 UX가 좋음'),
(2, 7, 9, 'PASS', '쿼리 최적화가 잘 되어 있음'),
(5, 1, 4, 'PASS', 'HTML/CSS 마크업 구조 좋음');