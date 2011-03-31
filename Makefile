all:

test-db:
	echo "CREATE DATABASE task;" > db/task.sql.tmp
	echo "USE task;" >> db/task.sql.tmp
	cat db/task.sql >> db/task.sql.tmp
	mysql -unobody -pnobody < db/task.sql.tmp

	echo "CREATE DATABASE task_test;" > db/task.sql.tmp
	echo "USE task_test;" >> db/task.sql.tmp
	cat db/task.sql >> db/task.sql.tmp
	mysql -unobody -pnobody < db/task.sql.tmp

	rm db/task.sql.tmp

test:
	prove t/moco/*.t
