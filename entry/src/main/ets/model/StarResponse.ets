import { UserResponse } from './UserResponse'

export class StarResponse {
  name: string = ''
  description: string = ''
  owner: UserResponse = new UserResponse()
  updated_at: string = ''
}