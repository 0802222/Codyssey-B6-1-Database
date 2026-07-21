USE codyssey_mission_db;

SELECT '1. 조회' AS info;
-- 1) 기본 조회: 전체 학생 목록 (트랙 기준 정렬)
-- 학생 테이블의 기본 조회와 ORDER BY 사용 예시
SELECT id, name, email, track, created_at
FROM student
ORDER BY track ASC, name ASC;

-- 2) 기본 조회: 특정 트랙의 학생만 조회
-- WHERE로 조건 검색, LIMIT로 상위 몇 명만 보기
SELECT id, name, email
FROM student
WHERE track = '백엔드'
ORDER BY created_at DESC
LIMIT 5;

-- 3) 기본 조회: 진행 중인 미션 목록
-- 진도 테이블에서 상태가 IN_PROGRESS인 레코드 조회
SELECT mp.id, mp.student_id, mp.mission_id, mp.status, mp.updated_at
FROM mission_progress mp
WHERE mp.status = 'IN_PROGRESS'
ORDER BY mp.updated_at DESC;

-- 4) 기본 조회: 아직 평가 결과가 PENDING인 진도
-- final_result가 PENDING인 학생-미션 조합 조회
SELECT mp.student_id, mp.mission_id, mp.status, mp.final_result
FROM mission_progress mp
WHERE mp.final_result = 'PENDING';

SELECT '2. JOIN' AS info;
-- 5) JOIN: 학생별 미션 제목과 상태 같이 보기 (INNER JOIN)
-- student + mission_progress + mission 조인으로 상세 진도 정보 확인
SELECT
    s.name        AS student_name,
    m.title       AS mission_title,
    mp.status,
    mp.final_result,
    mp.updated_at
FROM mission_progress mp
INNER JOIN student s ON mp.student_id = s.id
INNER JOIN mission  m ON mp.mission_id = m.id
ORDER BY s.name, m.title;

-- 6) JOIN: 특정 미션(B3-1)에 대한 학생별 진도 현황 (INNER JOIN + WHERE)
-- Codyssey 미션 관리 DB 설계 미션에 대한 진도만 필터링
SELECT
    s.name AS student_name,
    mp.status,
    mp.final_result,
    mp.submitted_at
FROM mission_progress mp
INNER JOIN student s ON mp.student_id = s.id
INNER JOIN mission  m ON mp.mission_id = m.id
WHERE m.title = 'B3-1 Codyssey 미션 관리 DB 설계'
ORDER BY s.name;

-- 7) JOIN: 동료평가 포함해서 학생별 평가 내역 보기 (INNER JOIN)
-- peer_review와 student/mission을 조인해 누가 누구를 어떻게 평가했는지 조회
SELECT
    m.title               AS mission_title,
    reviewer.name         AS reviewer_name,
    reviewee.name         AS reviewee_name,
    pr.review_result,
    pr.comment,
    pr.reviewed_at
FROM peer_review pr
INNER JOIN mission  m       ON pr.mission_id = m.id
INNER JOIN student reviewer ON pr.reviewer_student_id = reviewer.id
INNER JOIN student reviewee ON pr.reviewee_student_id = reviewee.id
ORDER BY m.title, reviewee.name;

-- 8) JOIN: 진도는 있는데 동료평가가 없는 학생-미션 찾기 (LEFT JOIN)
-- mission_progress LEFT JOIN peer_review 후, 평가가 하나도 없는 케이스 확인
SELECT
    s.name  AS student_name,
    m.title AS mission_title,
    mp.status,
    mp.final_result
FROM mission_progress mp
INNER JOIN student s ON mp.student_id = s.id
INNER JOIN mission  m ON mp.mission_id = m.id
LEFT JOIN peer_review pr
  ON pr.mission_id = mp.mission_id
 AND pr.reviewee_student_id = mp.student_id
WHERE pr.id IS NULL;

SELECT '3. 집계' AS info;
-- 9) 집계: 미션별 참여 학생 수 (COUNT + GROUP BY)
-- mission_progress 기준으로 각 미션에 몇 명이 참여했는지 집계
SELECT
    m.title AS mission_title,
    COUNT(mp.student_id) AS participant_count
FROM mission_progress mp
INNER JOIN mission m ON mp.mission_id = m.id
GROUP BY m.id, m.title
ORDER BY participant_count DESC;

-- 10) 집계: 학생별 완수한 미션 수 (COUNT + GROUP BY)
-- status = DONE 또는 final_result = PASS인 경우를 완수로 보고 집계
SELECT
    s.name AS student_name,
    COUNT(*) AS completed_mission_count
FROM mission_progress mp
INNER JOIN student s ON mp.student_id = s.id
WHERE mp.status = 'DONE'
   OR mp.final_result = 'PASS'
GROUP BY s.id, s.name
ORDER BY completed_mission_count DESC;

-- 11) 집계: 동료평가 PASS/FAIL 비율 (COUNT + GROUP BY)
-- 미션별로 PASS/FAIL 횟수를 집계해서 코드 리뷰 품질을 확인
SELECT
    m.title AS mission_title,
    pr.review_result,
    COUNT(*) AS count_by_result
FROM peer_review pr
INNER JOIN mission m ON pr.mission_id = m.id
GROUP BY m.id, m.title, pr.review_result
ORDER BY m.title, pr.review_result;

SELECT '4. 서브쿼리' AS info;
-- 12) 서브쿼리: 동료평가를 한 번도 받아보지 않은 학생 찾기
-- 서브쿼리로 peer_review의 reviewee 목록을 뽑고, NOT IN으로 필터링
SELECT
    s.id,
    s.name,
    s.email
FROM student s
WHERE s.id NOT IN (
    SELECT DISTINCT pr.reviewee_student_id
    FROM peer_review pr
);

-- 13) UPDATE: 동료평가 집계를 반영해 final_result 갱신
-- 3개의 동료평가 결과를 집계해서 PASS/FAIL/PENDING으로 최종 결과를 업데이트
UPDATE mission_progress mp
JOIN (
    SELECT
        pr.reviewee_student_id AS student_id,
        pr.mission_id,
        COUNT(*) AS review_count,
        SUM(CASE WHEN pr.review_result = 'PASS' THEN 1 ELSE 0 END) AS pass_count,
        SUM(CASE WHEN pr.review_result = 'FAIL' THEN 1 ELSE 0 END) AS fail_count
    FROM peer_review pr
    GROUP BY pr.reviewee_student_id, pr.mission_id
) agg
  ON agg.student_id = mp.student_id
 AND agg.mission_id = mp.mission_id
SET mp.final_result =
    CASE
        WHEN agg.review_count = 3 AND agg.pass_count = 3 THEN 'PASS'
        WHEN agg.review_count = 3 AND agg.fail_count >= 1 THEN 'FAIL'
        ELSE 'PENDING'
    END,
    mp.updated_at = CURRENT_TIMESTAMP;

-- 14) UPDATE: 특정 미션의 상태를 수동으로 DONE으로 변경
-- 제출 완료된 미션 중 아직 DONE 처리 안 된 경우 상태 업데이트 예시
UPDATE mission_progress
SET status = 'DONE',
    updated_at = CURRENT_TIMESTAMP
WHERE mission_id = 3   -- B3-1 Codyssey 미션 관리 DB 설계
  AND status = 'SUBMITTED';

-- 15) DELETE: 테스트용 동료평가 데이터 삭제
-- 특정 미션에 대한 임시 동료평가 데이터를 정리하는 예시
DELETE FROM peer_review
WHERE mission_id = 1
  AND reviewer_student_id = 5
  AND reviewee_student_id = 3;

-- 16) 인덱스: 동료평가 조회용 인덱스 생성
-- reviewee_student_id + mission_id 조합으로 자주 조회할 때 성능 향상을 위해 인덱스 추가
CREATE INDEX idx_peer_review_reviewee_mission
ON peer_review (reviewee_student_id, mission_id);

-- 17) 인덱스: 진도 조회용 인덱스 생성
-- 특정 미션의 상태를 많이 조회할 경우 mission_id + status 인덱스로 필터링 성능 개선
CREATE INDEX idx_mission_progress_mission_status
ON mission_progress (mission_id, status);