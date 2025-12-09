import { getConnection } from './db_connection.js'

const main = () => {
    // Get DB connection
    const connection = getConnection();
    if (connection) {
        console.log('Database connection established successfully.');
    }

}
main()