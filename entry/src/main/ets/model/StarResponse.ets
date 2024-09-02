import { UserResponse } from './UserResponse'

export class StarResponse {
  name: string = ''
  humman_name: string = ''
  name_with_namespace: string = ''
  full_name: string = ''
  description: string = ''
  owner: UserResponse = new UserResponse()
  updated_at: string = ''
  starred: boolean = false
}