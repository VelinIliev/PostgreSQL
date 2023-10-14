-- 01. User-defined Function Full Name

CREATE OR REPLACE FUNCTION fn_full_name(first_name VARCHAR(50), last_name VARCHAR(50))
RETURNS VARCHAR
AS $$
BEGIN
    RETURN INITCAP(CONCAT(first_name, ' ', last_name));
END;
$$ LANGUAGE plpgsql;

SELECT fn_full_name('Ivan', 'Petrov') AS full_name;

-- 02. User-defined Function Future Value

CREATE OR REPLACE FUNCTION fn_calculate_future_value(
    initial_sum NUMERIC,
    yearly_interest_rate NUMERIC,
    number_of_years NUMERIC)
RETURNS VARCHAR
AS $$
BEGIN
    RETURN TO_CHAR(TRUNC(initial_sum * ((1 + yearly_interest_rate) ^ number_of_years), 4), '9999999999999.9999');
END;
$$ LANGUAGE plpgsql;

SELECT fn_calculate_future_value (1000, 0.1, 5) AS output;
SELECT fn_calculate_future_value(2500, 0.30, 2) AS output;
SELECT fn_calculate_future_value(500, 0.25, 10) AS output;

-- 03. User-defined Function Is Word Comprised

CREATE OR REPLACE FUNCTION fn_is_word_comprised(
    set_of_letters VARCHAR(50),
    word VARCHAR(50))
RETURNS bool
AS $$
DECLARE
    i INT;
    letter CHAR(1);
    set_of_letters_lowercase VARCHAR(50);
    word_lowercase VARCHAR(50);
BEGIN
    set_of_letters_lowercase = LOWER(set_of_letters);
    word_lowercase = LOWER(word);

    i = 1;
    WHILE i <= LENGTH(word_lowercase) LOOP
        letter = SUBSTRING(word_lowercase FROM i FOR 1);
        IF POSITION(letter IN set_of_letters_lowercase) = 0 THEN
            RETURN FALSE;
        END IF;
        i = i + 1;
    END LOOP;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

SELECT fn_is_word_comprised('ois tmiah%f', 'halves');
SELECT fn_is_word_comprised('ois tmiah%f', 'Sofia');
SELECT fn_is_word_comprised('bobr', 'Rob');
SELECT fn_is_word_comprised('papopep', 'toe');
SELECT fn_is_word_comprised('R@o!B$B', 'Bob');

-- 04. Game Over

CREATE OR REPLACE FUNCTION fn_is_game_over(is_game_over BOOLEAN)
RETURNS TABLE (game_name VARCHAR(50), game_type_id INT, is_finished BOOL) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.name AS "name",
        g.game_type_id,
        g.is_finished
    FROM games g
    WHERE g.is_finished = is_game_over;
END;
$$ LANGUAGE plpgsql;

SELECT fn_is_game_over(true);
SELECT fn_is_game_over(false);

-- 05. Difficulty Level

CREATE OR REPLACE FUNCTION fn_difficulty_level(level INT)
RETURNS VARCHAR(50) AS $$
BEGIN
    IF level <= 40 THEN
        RETURN 'Normal Difficulty';
    ELSIF level BETWEEN 41 AND 60 THEN
        RETURN 'Nightmare Difficulty';
    ELSE RETURN 'Hell Difficulty';
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT
    ug.user_id,
    ug.level,
    ug.cash,
    fn_difficulty_level(ug.level) AS difficulty_level
FROM users_games ug
ORDER BY ug.user_id;

-- 06. Cash in User Games Odd Rows

CREATE OR REPLACE FUNCTION fn_cash_in_users_games(game_name VARCHAR(50))
RETURNS TABLE (total_cash NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT ROUND(SUM(cash)::NUMERIC, 2) AS total_cash
    FROM (
        SELECT cash,
               ROW_NUMBER() OVER (ORDER BY cash DESC) AS row_num
        FROM users_games
        JOIN games g on g.id = users_games.game_id
        WHERE g.name = game_name
    ) AS ranked_rows
    WHERE row_num % 2 <> 0;
END;
$$ LANGUAGE plpgsql;

SELECT fn_cash_in_users_games('Love in a mist');
SELECT fn_cash_in_users_games('Delphinium Pacific Giant');

-- 08. Deposit Money

CREATE OR REPLACE PROCEDURE sp_deposit_money(
    account_id INT,
    money_amount NUMERIC(20, 4)
    )
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
            SELECT 1 FROM accounts
            WHERE id = account_id
        ) THEN
        UPDATE accounts
        SET balance = balance + money_amount
        WHERE id = account_id;
        COMMIT;
    END IF;
END; $$;

CALL sp_deposit_money(1, 200);

SELECT * FROM accounts
WHERE id = 1;

-- 09. Withdraw Money
CREATE OR REPLACE PROCEDURE sp_withdraw_money(
    account_id INT,
    money_amount NUMERIC(20, 4)
    )

LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
            SELECT 1 FROM accounts
            WHERE id = account_id
        ) THEN
        IF (SELECT balance FROM accounts WHERE id = account_id ) > money_amount
            THEN
            UPDATE accounts
            SET balance = balance - money_amount
            WHERE id = account_id;
            COMMIT;
        ELSE RAISE NOTICE 'Insufficient balance for withdrawal.';
        END IF;
    END IF;
END; $$;

CALL sp_withdraw_money(1, 200);

SELECT * FROM accounts
WHERE id = 1;

-- 10. Money Transfer

CREATE OR REPLACE PROCEDURE sp_transfer_money(
    sender_id INT,
    receiver_id INT,
    amount NUMERIC(20, 4)
    )
LANGUAGE plpgsql
AS $$
DECLARE withdraw_successful BOOLEAN := TRUE;
DECLARE deposit_successful BOOLEAN := TRUE;
DECLARE rows_withdraw INT := 0;
DECLARE rows_deposit INT := 0;

BEGIN
    CALL sp_withdraw_money(sender_id, amount);
    GET DIAGNOSTICS rows_withdraw := ROW_COUNT;
    IF rows_withdraw > 0 THEN withdraw_successful := FALSE;
    END IF;

    IF withdraw_successful THEN
        CALL sp_deposit_money(receiver_id, amount);
        GET DIAGNOSTICS rows_deposit := ROW_COUNT;
        IF rows_deposit > 0 THEN deposit_successful := FALSE;
        END IF;
    END IF;

    IF withdraw_successful AND deposit_successful THEN
        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END; $$;

CALL sp_deposit_money(1, 200);
CALL sp_withdraw_money(2, 200);

CALL sp_transfer_money(1, 2, 100);

SELECT * FROM accounts
WHERE id IN (1,2);

-- 11. Delete Procedure

DROP PROCEDURE IF EXISTS sp_retrieving_holders_with_balance_higher_than;

-- 12. Log Accounts Trigger

CREATE TABLE logs (
    id SERIAL PRIMARY KEY,
    account_id INT,
    old_sum NUMERIC,
    new_sum NUMERIC
);

CREATE OR REPLACE FUNCTION trigger_fn_insert_new_entry_into_logs()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs (account_id, old_sum, new_sum)
    VALUES (OLD.id, OLD.balance, NEW.balance);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_account_balance_change
AFTER UPDATE OF balance ON accounts
FOR EACH ROW
WHEN (OLD.balance IS DISTINCT FROM NEW.balance)
EXECUTE FUNCTION trigger_fn_insert_new_entry_into_logs();

CALL sp_deposit_money(1, 0);
CALL sp_withdraw_money(1, 120);
SELECT * FROM logs
WHERE id  = 1 ;

-- 13. Notification Email on Balance Change

CREATE TABLE notification_emails (
    id SERIAL PRIMARY KEY,
    recipient_id INT,
    subject VARCHAR(255),
    body TEXT
);

CREATE OR REPLACE FUNCTION trigger_fn_send_email_on_balance_change()
RETURNS TRIGGER
AS $$
BEGIN
    INSERT INTO notification_emails (recipient_id, subject, body)
    VALUES (
        NEW.account_id,
        CONCAT('Balance change for account: ', NEW.account_id),
        CONCAT('On ' , DATE(NOW()), ' your balance was changed from ', NEW.old_sum, ' to ', NEW.new_sum, '.')
    );
    RETURN NEW;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_send_email_on_balance_change
AFTER UPDATE OF new_sum ON logs
FOR EACH ROW
EXECUTE FUNCTION trigger_fn_send_email_on_balance_change();

UPDATE logs
SET new_sum = 100
WHERE id = 1

