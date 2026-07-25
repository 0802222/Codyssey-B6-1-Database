USE codyssey_mission_db;

SELECT '1. 조회' AS info;
-- 1) 전체 학생 목록 (트랙 기준 정렬)
SELECT '전체 학생 목록 (트랙 기준 정렬)' AS info;
SELECT id, name, email, track, created_at
FROM student
ORDER BY track ASC, name ASC;

-- 2) 특정 트랙의 학생만 조회
SELECT '특정 트랙의 학생만 조회' AS info;
SELECT id, name, email
FROM student
WHERE track = 'AI SW Basic'
ORDER BY created_at DESC
LIMIT 5;

-- 3) 진행 중인 미션 목록
SELECT '진행 중인 미션 목록' AS info;
SELECT mp.id, mp.student_id, mp.mission_id, mp.status, mp.updated_at
FROM mission_progress mp
WHERE mp.status = 'IN_PROGRESS'
ORDER BY mp.updated_at DESC;

-- 4) 아직 평가 결과가 PENDING인 진도
SELECT '아직 평가 결과가 PENDING인 진도' AS info;
SELECT mp.student_id, mp.mission_id, mp.status, mp.final_result
FROM mission_progress mp
WHERE mp.final_result = 'PENDING';



SELECT '2. JOIN' AS info;
-- 5) 학생별 미션 제목과 상태 같이 보기 (INNER JOIN)
SELECT '학생별 미션 제목과 상태 같이 보기 (INNER JOIN)' AS info;
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

-- 6) 특정 미션(B3-1)에 대한 학생별 진도 현황 (INNER JOIN + WHERE)
SELECT '특정 미션(B3-1)에 대한 학생별 진도 현황 (INNER JOIN + WHERE)' AS info;
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

-- 7) 동료평가 포함해서 학생별 평가 내역 보기 (INNER JOIN)
SELECT '동료평가 포함해서 학생별 평가 내역 보기 (INNER JOIN)' AS info;
SELECT
    m.title               AS mission_title,
    reviewer.name         AS 평가자,
    reviewee.name         AS 피평가자,
    pr.review_result,
    pr.comment,
    pr.reviewed_at
FROM peer_review pr
INNER JOIN mission  m       ON pr.mission_id = m.id
INNER JOIN student reviewer ON pr.reviewer_student_id = reviewer.id
INNER JOIN student reviewee ON pr.reviewee_student_id = reviewee.id
ORDER BY m.title, reviewee.name;

-- 8) 진도는 있는데 동료평가가 없는 학생-미션 찾기 (LEFT JOIN)
SELECT '진도는 있는데 동료평가가 없는 학생-미션 찾기 (LEFT JOIN)' AS info;
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
-- 9) 미션별 참여 학생 수 (COUNT + GROUP BY)
SELECT '미션별 참여 학생 수 (COUNT + GROUP BY)' AS info;
SELECT
    m.title AS mission_title,
    COUNT(mp.student_id) AS participant_count
FROM mission_progress mp
INNER JOIN mission m ON mp.mission_id = m.id
GROUP BY m.id, m.title
ORDER BY participant_count DESC;

-- 10) 학생별 완수한 미션 수 (COUNT + GROUP BY)
SELECT '학생별 완수한 미션 수 (COUNT + GROUP BY)' AS info;
SELECT
    s.name AS student_name,
    COUNT(*) AS completed_mission_count
FROM mission_progress mp
INNER JOIN student s ON mp.student_id = s.id
WHERE mp.status = 'DONE'
   OR mp.final_result = 'PASS'
GROUP BY s.id, s.name
ORDER BY completed_mission_count DESC;

-- 11) 동료평가 PASS/FAIL 비율 (COUNT + GROUP BY)
SELECT '동료평가 PASS/FAIL 비율 (COUNT + GROUP BY)' AS info;

SELECT
    mission_title,
    review_result,
    count_by_result,
    ROUND(
        count_by_result
        / SUM(count_by_result) OVER (PARTITION BY mission_title)
        * 100,
        1
    ) AS ratio_percent
FROM (
    SELECT
        m.title          AS mission_title,
        r.review_result  AS review_result,
        COALESCE(COUNT(pr.id), 0) AS count_by_result
    FROM mission m
    CROSS JOIN (
        SELECT 'PASS' AS review_result
        UNION ALL
        SELECT 'FAIL'
    ) r
    LEFT JOIN peer_review pr
        ON pr.mission_id = m.id
       AND pr.review_result = r.review_result
    GROUP BY m.id, m.title, r.review_result
) t
ORDER BY mission_title, review_result;

SELECT '4. 서브쿼리' AS info;
-- 12) 동료평가를 한 번도 받아보지 않은 학생 찾기
SELECT '동료평가를 한 번도 받아보지 않은 학생 찾기' AS info;
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
UPDATE mission_progress
SET status = 'DONE',
    updated_at = CURRENT_TIMESTAMP
WHERE mission_id = 3   -- B3-1 Codyssey 미션 관리 DB 설계
  AND status = 'SUBMITTED';

-- 15) DELETE: 테스트용 동료평가 데이터 삭제
DELETE FROM peer_review
WHERE mission_id = 1
  AND reviewer_student_id = 5
  AND reviewee_student_id = 3;

-- 16) 인덱스: 동료평가 조회용 인덱스 생성
CREATE INDEX idx_peer_review_reviewee_mission
ON peer_review (reviewee_student_id, mission_id);

-- 17) 인덱스: 진도 조회용 인덱스 생성
CREATE INDEX idx_mission_progress_mission_status
ON mission_progress (mission_id, status);