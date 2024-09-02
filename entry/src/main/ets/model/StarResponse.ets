import { UserResponse } from './UserResponse'

export class StarResponse {
  name: string = ''
  humman_name: string = ''
  fullName: string = ''
  description: string = ''
  owner: UserResponse = new UserResponse()
  updated_at: string = ''
}