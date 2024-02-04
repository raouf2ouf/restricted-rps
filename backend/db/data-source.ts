import { DataSource } from 'typeorm';

import { dataSourceOptions } from './db-config';

const dataSource = new DataSource(dataSourceOptions);
export default dataSource;
